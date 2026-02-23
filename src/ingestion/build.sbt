ThisBuild / version      := "0.1.0"
ThisBuild / scalaVersion := "2.13.14"
ThisBuild / organization := "com.datakata"

lazy val root = (project in file("."))
  .settings(
    name := "ingestion",
    libraryDependencies ++= Seq(
      "org.apache.kafka"           %  "kafka-clients"   % "3.7.0",
      "io.circe"                   %% "circe-core"      % "0.14.9",
      "io.circe"                   %% "circe-generic"   % "0.14.9",
      "io.circe"                   %% "circe-parser"    % "0.14.9",
      "com.typesafe"               %  "config"          % "1.4.3",
      "ch.qos.logback"             %  "logback-classic" % "1.5.6",
      "com.typesafe.scala-logging" %% "scala-logging"   % "3.9.5",
      "com.github.tototoshi"       %% "scala-csv"       % "1.3.10",
    ),
    assembly / assemblyJarName := "ingestion-assembly-0.1.0.jar",
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", _*) => MergeStrategy.discard
      case "reference.conf"         => MergeStrategy.concat
      case _                        => MergeStrategy.first
    },
  )
