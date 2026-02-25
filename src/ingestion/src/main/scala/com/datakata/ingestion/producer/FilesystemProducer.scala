package com.datakata.ingestion.producer

import com.datakata.ingestion.config.KafkaConfig
import com.datakata.ingestion.model.Sale
import com.github.tototoshi.csv.CSVReader
import com.typesafe.config.ConfigFactory
import com.typesafe.scalalogging.LazyLogging
import io.circe.syntax._
import org.apache.kafka.clients.producer.{Callback, KafkaProducer, ProducerRecord, RecordMetadata}

import java.io.File

object FilesystemProducer extends LazyLogging {
  private val config = ConfigFactory.load()

  def run(): Unit = {
    val csvPath = config.getString("sales.csv-path")
    val topic   = config.getString("sales.topic")

    val producer = new KafkaProducer[String, String](KafkaConfig.producerProps("filesystem-producer"))

    try {
      val reader = CSVReader.open(new File(csvPath))
      val rows   = reader.allWithHeaders()
      reader.close()

      rows.foreach { row =>
        val sale = Sale(
          saleId      = row("sale_id"),
          productName = row("product_name"),
          city        = row("city"),
          salesman    = row("salesman"),
          amount      = row("amount").toDouble,
          saleDate    = row("sale_date"),
        )
        val record = new ProducerRecord[String, String](topic, sale.saleId, sale.asJson.noSpaces)

        producer.send(record, new Callback {
          override def onCompletion(metadata: RecordMetadata, exception: Exception): Unit =
            if (exception != null)
              logger.error(s"Delivery failed for sale ${sale.saleId}: ${exception.getMessage}")
            else
              logger.info(
                s"Delivered sale ${sale.saleId} (${sale.salesman}, ${sale.city}) → ${metadata.topic()}[${metadata.partition()}]@${metadata.offset()}"
              )
        })
      }

      producer.flush()
      logger.info(s"Ingestion complete — published ${rows.size} sales records to '$topic'")
    } finally {
      producer.close()
    }
  }
}
