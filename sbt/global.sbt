
commands += Command.command("clearCsrCache") { state =>

    Option(System.getProperty("sbt.coursier.home")).map { cacheLocation =>
        val cacheLocationBackup = cacheLocation + ".bak"
        println("backup and empty the coursier cache " + cacheLocation + " to " + cacheLocationBackup)
        import sys.process._
        Seq("mv", cacheLocation, cacheLocationBackup) !;
        Seq("mkdir", "-p", cacheLocation) !;
    }

    state
}


