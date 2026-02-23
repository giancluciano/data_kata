package com.datakata.ingestion

import com.datakata.ingestion.producer.FilesystemProducer
import com.typesafe.scalalogging.LazyLogging

object Main extends App with LazyLogging {
  logger.info("Starting ingestion pipeline")
  FilesystemProducer.run()
  logger.info("Ingestion pipeline finished")
}
