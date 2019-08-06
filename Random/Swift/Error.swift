import Foundation
import Darwin

func exitByError(_ message:String) {
    fputs("\(message)\n",stderr)
    exit(1)
}