import Commander
import Foundation

enum UsedModelName {
    case GEMINI
    case CLAUDE
    case Llama
}

let prompt =
    "You are an expert in shell scripting, and you are on {os}, you receive the user request and process it, then you give a full bash shell script to do it, you do not give explanations at all, you reply only with the bash script. If some tools are needed, you verify firstly if they are not installed, then you add the command to install them. Also you just give the needed bash shell script without any comment at all. You are now in {cwd}, do the following: {request}"

private func fillPrompt(userOperatingSystem: String, currentWorkingDirectory: String, request: String) -> String {
    var filledContent = prompt
    let answers = [
        "os": userOperatingSystem,
        "cwd": currentWorkingDirectory,
        "request": request
    ]
    for (placeholder, answer) in answers {
        filledContent = filledContent.replacingOccurrences(of: "{\(placeholder)}", with: answer)
    }
    return filledContent
}

private func isValidShellScript(_ string: String) -> Bool {
    guard let data = string.data(using: .utf8) else {
        return false
    }
    // TODO: Complete this
    return true
}

func runShellScript(_ scriptPath: String) {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe

    #if os(macOS)
    process.launchPath = "/usr/bin/open"
    process.arguments = ["-a", "Terminal.app", scriptPath]
    #else
    process.launchPath = "/usr/bin/gnome-terminal"
    process.arguments = ["--", "/bin/bash", "-c", "chmod +x '\(scriptPath)'; '\(scriptPath)'; exec bash"]
    #endif

    do {
        try process.run()
    } catch {
        print("Failed to start process: \(error)")
    }
}

func getOSName() -> String {
    #if os(Linux)
    let osReleaseContents = try? String(contentsOfFile: "/etc/os-release", encoding: .utf8)
    let lines = osReleaseContents?.split(separator: "\n") ?? []
    for line in lines {
        if line.starts(with: "PRETTY_NAME=") {
            let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
            if parts.count > 1 {
                var quotesCharacterSet = CharacterSet()
                quotesCharacterSet.insert(charactersIn: "\"'")
                let osName = parts[1].trimmingCharacters(in: quotesCharacterSet)
                return "Linux (type: \(osName))"
            }
        }
    }
    return "Linux"
    #elseif os(macOS)
    return "macOS"
    #else
    return "Unknown"
    #endif
}

func getConfig() -> [String: Any]? {
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
    let filePath = homeDirectory.appendingPathComponent(".shexec.yml")

    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath.path) {
        do {
            let content = try String(contentsOf: filePath, encoding: .utf8)
            return YamlHelper.decode(content)
        } catch {
            TerminalHelper.printInColors("Error reading ~/.shexec.yml file: \(error)", color: .red, style: .bold)
        }
    } else {
        TerminalHelper.printInColors(
            "What AI model would you like to use ? ",
            color: .blue,
            style: .bold)
        print("")
        TerminalHelper.printInColors(
            "1. Gemini",
            color: .green,
            style: .bold)
        TerminalHelper.printInColors(
            "2. Claude",
            color: .green,
            style: .bold)
        TerminalHelper.printInColors(
            "3. Llama",
            color: .green,
            style: .bold)
        var isLocalModel = false
        let model = readLine()
        var modelName = ""
        if model == "1" {
            modelName = GeminiModel.shared.name
            isLocalModel = GeminiModel.shared.isLocal
            TerminalHelper.printInColors(
                "Please enter your Gemini API KEY (Get it from: https://aistudio.google.com/app/apikey): ",
                color: .teal,
                style: .bold)
        } else if model == "2" {
            modelName = ClaudeModel.shared.name
            isLocalModel = ClaudeModel.shared.isLocal
            TerminalHelper.printInColors(
                "Please enter your Claude API KEY (Get it from: https://console.anthropic.com/settings/keys): ",
                color: .teal,
                style: .bold)
        } else {
            modelName = LlamaModel.shared.name
            isLocalModel = LlamaModel.shared.isLocal
        }

        var apiKey = ""
        if !isLocalModel {
            apiKey = readLine() ?? ""
        }
        let dictionary = [
            "MODEL": modelName,
            "API_KEY": apiKey
        ]
        let content = YamlHelper.encode(dictionary)
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            TerminalHelper.printInColors(
                "~/.shexec.yml config file has been created successfully !",
                color: .green,
                style: .bold)
            return dictionary
        } catch {
            TerminalHelper.printInColors("Error creating ~/.shexec.yml file: \(error)", color: .red, style: .bold)
        }
    }

    return nil
}

let main = command { (userRequest: String) in

    let userOperatingSystem = getOSName()
    let config = getConfig()
    let currentWorkingDirectory = FileManager.default.currentDirectoryPath
    let semaphore = DispatchSemaphore(value: 0)
    var usedModel: Model
    var usedModelName: UsedModelName
    if config!["MODEL"] as! String == "Gemini 1.0 Pro" {
        usedModelName = .GEMINI
        usedModel = GeminiModel.shared
    } else if config!["MODEL"] as! String == "Claude-3-opus-20240229" {
        usedModelName = .CLAUDE
        usedModel = ClaudeModel.shared
    } else {
        usedModelName = .Llama
        usedModel = LlamaModel.shared
    }
    if !usedModel.isLocal {
        usedModel.setApiKey(config!["API_KEY"] as! String)
    }
    let filledPrompt = fillPrompt(
        userOperatingSystem: userOperatingSystem,
        currentWorkingDirectory: currentWorkingDirectory,
        request: userRequest)
    usedModel.generate(prompt: filledPrompt) { result in
        switch result {
        case let .success(data):
            do {
                let decoder = JSONDecoder()
                var fullResponse = ""
                TerminalHelper.printInColors("Generating Shell Script ...", color: .teal, style: .bold)
                switch usedModelName {
                case .GEMINI:
                    let response = try decoder.decode(GeminiResponse.self, from: data)
                    fullResponse = response.candidates.first!.content.parts.first!.text
                case .CLAUDE:
                    let response = try decoder.decode(ClaudeResponse.self, from: data)
                    fullResponse = response.content.first!.text!
                case .Llama:
                    let response = try decoder.decode(LlamaResponse.self, from: data)
                    fullResponse = response.message.content
                }

                var commands = fullResponse.replacingOccurrences(of: "```shell", with: "")
                commands = commands.replacingOccurrences(of: "```", with: "")
                // commands = commands.replacingOccurrences(of: "#!/bin/bash", with: "")
                commands = commands.replacingOccurrences(of: "bash", with: "")
                let confirmRun = """
                    echo "Press 'r' key to run the generated bash script, any other key to abort."
                    read -n 1 -s -r -p "Waiting for input: " input
                    echo ""
                    if [ "$input" == "r" ]; then
                        echo "Running the script..."
                    else
                        echo "Aborted."
                        exit 1
                    fi
                    """
                commands = "\(confirmRun)\n cd \(currentWorkingDirectory)\n\(commands)"

                TerminalHelper.printInColors(commands, color: .black, style: .bold)

                let currentDirectoryPath = FileManager.default.currentDirectoryPath
                let scriptPath = "\(currentDirectoryPath)/script.sh"

                do {
                    try commands.write(toFile: scriptPath, atomically: true, encoding: .utf8)
                } catch {
                    TerminalHelper.printInColors("Error writing to script file: \(error)", color: .red, style: .bold)
                    return
                }

                let chmodCommand = "chmod +x \(scriptPath)"
                Process.launchedProcess(launchPath: "/bin/bash", arguments: ["-c", chmodCommand])
                runShellScript(scriptPath)

                TerminalHelper.printInColors("Operation completed !", color: .green, style: .bold)

            } catch {
                TerminalHelper.printInColors("Failed to decode JSON: \(error)", color: .red, style: .bold)
            }

            semaphore.signal()
        case let .failure(error):
            TerminalHelper.printInColors("Error: \(error.localizedDescription)", color: .red, style: .bold)
            semaphore.signal()
        }
    }
    semaphore.wait()
}

main.run()
