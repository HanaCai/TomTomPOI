//
//  ResponseModel.swift
//  TestApp
//
//  Created by Hana Cai on 12/29/2022.
//

import Foundation

// MARK: - ResponseModel
struct ResponseModel: Codable {
    let summary: Summary
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let type: String?
    let id: String?
    let score, dist: Double?
    let info: String?
    let poi: Poi?
    let address: Address?
    let position: GeoBias?
    let viewport: Viewport?
    let entryPoints: [EntryPoint]?
}

// MARK: - Address
struct Address: Codable {
    let streetNumber, streetName: String?
    let municipality, countrySecondarySubdivision: String?
    let countrySubdivision: String?
    let countrySubdivisionName: String?
    let postalCode: String?
    let extendedPostalCode: String?
    let countryCode: String?
    let country: String?
    let countryCodeISO3: String?
    let freeformAddress: String?
    let localName: String?
}

// MARK: - EntryPoint
struct EntryPoint: Codable {
    let type: String?
    let position: GeoBias?
}

// MARK: - GeoBias
struct GeoBias: Codable {
    let lat, lon: Double
}

// MARK: - Poi
struct Poi: Codable {
    let name: String?
    let phone: String?
    let categorySet: [CategorySet]?
    let categories: [String]?
    let classifications: [Classification]?
    let url: String?
}

// MARK: - CategorySet
struct CategorySet: Codable {
    let id: Int?
}

// MARK: - Classification
struct Classification: Codable {
    let code: String?
    let names: [Name]?
}

// MARK: - Name
struct Name: Codable {
    let nameLocale: String?
    let name: String?
}


// MARK: - Viewport
struct Viewport: Codable {
    let topLeftPoint, btmRightPoint: GeoBias?
}

// MARK: - Summary
struct Summary: Codable {
    let queryType: String?
    let queryTime, numResults, offset, totalResults: Int?
    let fuzzyLevel: Int?
    let geoBias: GeoBias?
}
