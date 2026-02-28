ThisBuild / scalaVersion := "2.13.14"
ThisBuild / version      := "0.1.0"

lazy val root = (project in file("."))
  .settings(
    name := "ingestion",
    libraryDependencies ++= Seq(
      "org.apache.kafka"           %  "kafka-clients"   % "3.7.0",
      "com.typesafe"               %  "config"          % "1.4.3",
      "com.typesafe.scala-logging" %% "scala-logging"   % "3.9.5",
      "ch.qos.logback"             %  "logback-classic" % "1.5.6",
      "com.github.tototoshi"       %% "scala-csv"       % "1.3.10",
      "io.circe"                   %% "circe-core"      % "0.14.7",
      "io.circe"                   %% "circe-generic"   % "0.14.7",
    ),
    assembly / assemblyJarName := "ingestion.jar",
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", "MANIFEST.MF") => MergeStrategy.discard
      case PathList("META-INF", xs @ _*)       => MergeStrategy.first
      case "reference.conf"                    => MergeStrategy.concat
      case _                                   => MergeStrategy.first
    },
  )
