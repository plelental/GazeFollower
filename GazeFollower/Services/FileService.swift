//
//  FileService.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation

class FileService {

    func getFileUrl(fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsDirectory.appendingPathComponent(fileName)
    }
}
