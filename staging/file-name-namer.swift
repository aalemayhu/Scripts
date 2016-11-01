import Foundation

func run() {
    let args = Process.arguments.dropFirst()
    guard args.count > 0 else {
        print("Please supply strings to be used for the name")
        return
    }
		// The first element is the application name, which we don't care about in
		// this case.
    let joined = args.joinWithSeparator("-")
    print (joined.lowercaseString)
}

run()
