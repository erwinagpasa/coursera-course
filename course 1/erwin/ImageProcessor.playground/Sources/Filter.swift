//
//  Filter.swift
//  
//
//  Created by Developer on 28/12/2024.
//

public protocol Filter {
    var name: String { get }
    func apply(to image: RGBAImage) -> RGBAImage
}
