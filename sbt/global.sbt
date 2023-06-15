

def clearCacheCommand(command: String, name: String, key: String) = Command.command(command) { state =>

    Option(System.getProperty(key)).map { cacheLocation =>
        val cacheLocationBackup = cacheLocation + ".bak"
        println("backup and empty the " + name + " cache from " + cacheLocation + " to " + cacheLocationBackup)
        import sys.process._
        Seq("mv", cacheLocation, cacheLocationBackup) !;
        Seq("mkdir", "-p", cacheLocation) !;
    }

    state
}

commands += clearCacheCommand("clearCsrCache", "coursier", "sbt.coursier.home")
commands += clearCacheCommand("clearIvyCache", "ivy", "sbt.ivy.home")

