package com.datakata.ingestion.model

import io.circe.generic.semiauto._
import io.circe.Encoder

case class Product(productId: String, productName: String, city: String)

object Product {
  implicit val encoder: Encoder[Product] = deriveEncoder[Product]
}
