"""Read-only Docker MCP server for sandboxed environments."""

import subprocess

from mcp.server import MCPServer

# Initialize MCP server (v2.x)
mcp = MCPServer("ReadOnlyDocker")


def _validate_container_id(container_name_or_id: str) -> str | None:
    """Validates container name or ID to prevent option injection."""
    if not container_name_or_id or container_name_or_id.startswith("-"):
        return "Error: Invalid container name or ID."
    return None


def run_host_docker_cmd(args: list[str]) -> str:
    """Helper to run docker commands securely and capture output."""
    try:
        # shell=False (the default) ensures arguments are passed securely
        # check=True will raise an exception if the command fails
        cmd = ["docker"] + args
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            timeout=10,  # Prevent hanging commands
        )
        # Return stdout if successful, or combine if needed
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        msg = e.stderr.strip() or e.stdout.strip() or "Unknown error"
        return f"Error (Code {e.returncode}):\n{msg}"
    except subprocess.TimeoutExpired:
        return "Error: Command timed out after 10 seconds."
    except FileNotFoundError:
        return "Error: The 'docker' CLI is not installed or not in PATH."
    except Exception as e:  # pylint: disable=broad-exception-caught
        return f"Unexpected error: {str(e)}"


@mcp.tool()
def list_host_docker_images() -> str:
    """Lists all available docker images on the host machine."""
    fmt = "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
    return run_host_docker_cmd(["image", "ls", "--format", fmt])


@mcp.tool()
def list_host_docker_containers(all_containers: bool = False) -> str:
    """Lists docker containers on the host.

    Args:
        all_containers: If True, shows all (including stopped) containers.
                        If False, only shows running containers.
    """
    args = ["ps", "--format", "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"]
    if all_containers:
        args.insert(1, "-a")
    return run_host_docker_cmd(args)


@mcp.tool()
def get_host_docker_logs(container_name_or_id: str, tail: int = 200) -> str:
    """Fetches the recent logs for a specific docker container."""
    validation_err = _validate_container_id(container_name_or_id)
    if validation_err:
        return validation_err
    if tail <= 0:
        return "Error: 'tail' must be a positive integer."
    return run_host_docker_cmd(["logs", "--tail", str(tail), container_name_or_id])


@mcp.tool()
def inspect_host_docker_container(container_name_or_id: str) -> str:
    """Inspects a container to return its low-level JSON configuration.

    Useful for checking env vars, network mounts, and volumes.
    """
    validation_err = _validate_container_id(container_name_or_id)
    if validation_err:
        return validation_err
    return run_host_docker_cmd(["inspect", container_name_or_id])


@mcp.tool()
def get_host_docker_stats(container_name_or_id: str) -> str:
    """Gets a single snapshot of the CPU, RAM, and Network usage for a container."""
    validation_err = _validate_container_id(container_name_or_id)
    if validation_err:
        return validation_err
    return run_host_docker_cmd(["stats", "--no-stream", container_name_or_id])


@mcp.tool()
def get_host_docker_processes(container_name_or_id: str) -> str:
    """Lists the OS processes currently running inside the container."""
    validation_err = _validate_container_id(container_name_or_id)
    if validation_err:
        return validation_err
    return run_host_docker_cmd(["top", container_name_or_id])


if __name__ == "__main__":
    mcp.run()
