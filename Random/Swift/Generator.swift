import Foundation

func generator(_ c:inout Customize) {

	switch c.valueType {
		case .int:
			if c.defaultRange {
				if c.visible {
					c.exec={ print(arc4random()) }
				}
				else {
					c.exec={ arc4random() }
				}
			}
			else {
				let r = c.intRange
				if c.visible {
					c.exec={ print(Int.random(in: r)) }
				}
				else {
					c.exec={ let _ = Int.random(in: r) }
				}
			}
		case .real:
		let r = c.realRange
			if c.visible {
				c.exec={ print(Double.random(in: r)) }
			}
			else {
				c.exec={ let _ = Double.random(in: r) }
			}
	}

}