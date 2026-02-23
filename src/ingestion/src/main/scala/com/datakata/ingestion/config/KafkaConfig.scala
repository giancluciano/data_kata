package com.datakata.ingestion.config

import com.typesafe.config.ConfigFactory

import java.util.Properties

object KafkaConfig {
  private val config = ConfigFactory.load()

  val bootstrapServers: String = config.getString("kafka.bootstrap-servers")

  def producerProps(clientId: String): Properties = {
    val props = new Properties()
    props.put("bootstrap.servers", bootstrapServers)
    props.put("client.id", clientId)
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("acks", "all")
    props.put("retries", "3")
    props.put("enable.idempotence", "true")
    props
  }
}
