package com.datakata.ingestion.model

import io.circe.generic.semiauto._
import io.circe.Encoder

case class Sale(
    saleId: String,
    productName: String,
    city: String,
    salesman: String,
    amount: Double,
    saleDate: String,
)

object Sale {
  implicit val encoder: Encoder[Sale] = deriveEncoder[Sale]
}
