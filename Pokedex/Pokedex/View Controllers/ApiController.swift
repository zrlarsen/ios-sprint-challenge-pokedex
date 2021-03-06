//
//  ApiController.swift
//  Pokedex
//
//  Created by Zack Larsen on 12/6/19.
//  Copyright © 2019 Zack Larsen. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

class PokemonController {
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")
    
    func fetchDetails(for pokemonName: String, completion: @escaping (Result<Pokemon, NetworkError>) -> Void) {
        let pokemonDetailsURL = baseURL?.appendingPathComponent(pokemonName)
        let request = URLRequest(url: pokemonDetailsURL!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
                
            }
            
            if let error = error {
                print("Error recieving pokemon name data \(error)")
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                let pokemon = try
                    decoder.decode(Pokemon.self, from: data)
                completion(.success(pokemon))
                
            } catch {
                print("Error decoding pokemon objects: \(error)")
                completion(.failure(.noDecode))
                return
            }
            
        }.resume()
        
    }
    func fetchImage(at urlString: String, completion: @escaping (UIImage?) -> Void) {
        let imageUrl = URL(string: urlString)!
        
        var request = URLRequest(url: imageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching image:\(error)")
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)!
            completion(image)
        }.resume()
        
    }
    
    func addPokemon(pokemon: Pokemon) {
        // do stuff to add to the pokemons array
        pokemons.append(pokemon)
    }
    
    var pokemons: [Pokemon] = []
}

