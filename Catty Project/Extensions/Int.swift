//
//  Int.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 03.08.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

extension Int {
    func isInRange(_ range: ClosedRange<Int>) -> Bool {
        return range.contains(self)
    }
    
    func isInRange(_ range: Range<Int>) -> Bool {
        return range.contains(self)
    }
}
