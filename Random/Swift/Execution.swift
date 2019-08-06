import Foundation
import Dispatch

func execute(_ c:Customize) {
	if let e = c.exec {
		switch c.concurrent {
			case .serial:
				for _ in 0..<c.length {e()}
			case .Dispatch:
				let dg = DispatchGroup()
				let cdq = DispatchQueue(label: "Random", qos: .userInitiated, attributes: .concurrent)
				for _ in 0..<c.length {cdq.async(group: dg, execute: e)}
				dg.wait()
			case .DispatchSerial:
				let dg = DispatchGroup()
				let cdq = DispatchQueue(label: "Random", qos: .userInitiated)
				for _ in 0..<c.length {cdq.async(group: dg, execute: e)}
				dg.wait()
			case .Operation:
				let oq = OperationQueue()
				for _ in 0..<c.length {
					let bo = BlockOperation(block: e)
					oq.addOperation(bo)
				}
				oq.waitUntilAllOperationsAreFinished()
		}
	}
	else {
		exitByError("実行できませんでした")
	}
}