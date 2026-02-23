package com.datakata.ingestion.producer

import com.datakata.ingestion.config.KafkaConfig
import com.datakata.ingestion.model.Product
import com.github.tototoshi.csv.CSVReader
import com.typesafe.config.ConfigFactory
import com.typesafe.scalalogging.LazyLogging
import io.circe.syntax._
import org.apache.kafka.clients.producer.{Callback, KafkaProducer, ProducerRecord, RecordMetadata}

import java.io.File

object FilesystemProducer extends LazyLogging {
  private val config = ConfigFactory.load()

  def run(): Unit = {
    val csvPath = config.getString("products.csv-path")
    val topic   = config.getString("products.topic")

    val producer = new KafkaProducer[String, String](KafkaConfig.producerProps("filesystem-producer"))

    try {
      val reader = CSVReader.open(new File(csvPath))
      val rows   = reader.allWithHeaders()
      reader.close()

      rows.foreach { row =>
        val product = Product(
          productId   = row("product_id"),
          productName = row("product_name"),
          city        = row("city"),
        )
        val record = new ProducerRecord[String, String](topic, product.productId, product.asJson.noSpaces)

        producer.send(record, new Callback {
          override def onCompletion(metadata: RecordMetadata, exception: Exception): Unit =
            if (exception != null)
              logger.error(s"Delivery failed for ${product.productName}: ${exception.getMessage}")
            else
              logger.info(s"Delivered ${product.productName} → ${metadata.topic()}[${metadata.partition()}]@${metadata.offset()}")
        })
      }

      producer.flush()
      logger.info(s"Ingestion complete — published ${rows.size} products to '$topic'")
    } finally {
      producer.close()
    }
  }
}
