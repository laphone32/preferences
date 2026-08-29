"""YouCompleteMe (YCM) compilation flags configuration script."""

import logging
import os
import os.path

try:
    import ycm_core
except ImportError:
    ycm_core = None  # type: ignore

BASE_FLAGS = [
    '-Wall',
    '-Wextra',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-ferror-limit=10000',
    '-DNDEBUG',
    '-std=c++17',
    '-xc++',
    '-I/usr/lib/',
    '-I/usr/include/',
]

SOURCE_EXTENSIONS = [
    '.cpp',
    '.cc',
    '.c',
]

SOURCE_DIRECTORIES = [
    'src',
]

HEADER_EXTENSIONS = [
    '.h',
    '.hpp',
]

HEADER_DIRECTORIES = [
    'include',
]

BUILD_DIRECTORY = 'build'


def is_header_file(filename):
    """Check if a filename has a C/C++ header extension."""
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS


def get_compilation_info_for_file(database, filename):
    """Retrieve compilation information from compilation database."""
    if is_header_file(filename):
        basename = os.path.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_file = basename + extension
            if os.path.exists(replacement_file):
                info = database.GetCompilationInfoForFile(replacement_file)
                if info.compiler_flags_:
                    return info
            for header_dir in HEADER_DIRECTORIES:
                for source_dir in SOURCE_DIRECTORIES:
                    src_file = replacement_file.replace(header_dir, source_dir)
                    if os.path.exists(src_file):
                        info = database.GetCompilationInfoForFile(src_file)
                        if info.compiler_flags_:
                            return info
        return None
    return database.GetCompilationInfoForFile(filename)


def find_nearest(path, target, build_folder=None):
    """Find the nearest parent path containing target file or directory."""
    candidate = os.path.join(path, target)
    if os.path.isfile(candidate) or os.path.isdir(candidate):
        logging.info('Found nearest %s at %s', target, candidate)
        return candidate

    parent = os.path.dirname(os.path.abspath(path))
    if parent == path:
        raise RuntimeError('Could not find ' + target)

    if build_folder:
        candidate = os.path.join(parent, build_folder, target)
        if os.path.isfile(candidate) or os.path.isdir(candidate):
            logging.info(
                'Found nearest %s in build folder at %s', target, candidate
            )
            return candidate

    return find_nearest(parent, target, build_folder)


def make_relative_paths_in_flags_absolute(flags, working_directory):
    """Convert relative include paths in flags to absolute paths."""
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[len(path_flag):]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def flags_for_clang_complete(root):
    """Load flags from .clang_complete file if present."""
    try:
        clang_complete_path = find_nearest(root, '.clang_complete')
        with open(clang_complete_path, 'r', encoding='utf-8') as f:
            return f.read().splitlines()
    except (OSError, RuntimeError):
        return None


def flags_for_include(root):
    """Discover all include directories in git root."""
    try:
        try:
            include_path = os.path.abspath(
                os.path.join(find_nearest(root, '.git'), os.pardir)
            )
            while True:
                parent = os.path.abspath(os.path.join(include_path, os.pardir))
                if not os.path.isfile(os.path.join(parent, '.gitmodules')):
                    break
                include_path = parent
        except (OSError, RuntimeError):
            include_path = find_nearest(root, 'include')

        flags = []
        for dirroot, dirnames, _ in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.join(dirroot, dir_path)
                flags.append('-I' + real_path)
        return flags
    except (OSError, RuntimeError):
        return None


def flags_for_compilation_database(root, filename):
    """Extract flags from compile_commands.json if available."""
    try:
        compilation_db_path = find_nearest(
            root, 'compile_commands.json', BUILD_DIRECTORY
        )
        compilation_db_dir = os.path.dirname(compilation_db_path)
        logging.info(
            'Set compilation database directory to %s', compilation_db_dir
        )
        if not ycm_core:
            return None
        compilation_db = ycm_core.CompilationDatabase(compilation_db_dir)
        if not compilation_db:
            logging.info('Compilation database file found but unable to load')
            return None
        compilation_info = get_compilation_info_for_file(
            compilation_db, filename
        )
        if not compilation_info:
            logging.info(
                'No compilation info for %s in compilation database', filename
            )
            return None
        return make_relative_paths_in_flags_absolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_,
        )
    except (OSError, RuntimeError):
        return None


def FlagsForFile(filename):  # pylint: disable=invalid-name
    """YCM hook: return compilation flags dictionary for file."""
    root = os.path.realpath(filename)
    compilation_db_flags = flags_for_compilation_database(root, filename)
    if compilation_db_flags:
        final_flags = compilation_db_flags
    else:
        final_flags = list(BASE_FLAGS)
        clang_flags = flags_for_clang_complete(root)
        if clang_flags:
            final_flags.extend(clang_flags)
        include_flags = flags_for_include(root)
        if include_flags:
            final_flags.extend(include_flags)
    return {
        'flags': final_flags,
        'do_cache': True,
    }
