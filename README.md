# ShExec
> A CLI tool that runs shell scripts based on natural language descriptions

![](https://img.shields.io/badge/license-MIT-brown)
![](https://img.shields.io/badge/version-1.0.0-orange)
![](https://img.shields.io/badge/Commander-0.9.2-green)
![](https://img.shields.io/badge/Swift-5.9-blue)

## Installation

To install ShExec, run the following commands:

### For macOS (Universal) :
```bash
cd ~/Downloads
wget https://github.com/YassineLafryhi/ShExec/releases/download/1.0.0/ShExec-1.0.0-macOS-Universal.zip
unzip ShExec-1.0.0-macOS-Universal.zip
sudo mkdir -p /usr/local/bin
sudo mv shexec /usr/local/bin/shexec
sudo chmod +x /usr/local/bin/shexec
```

### For Linux (x86_64) :
```bash
cd ~/Downloads
wget https://github.com/YassineLafryhi/ShExec/releases/download/1.0.0/ShExec-1.0.0-linux-x86_64.zip
unzip ShExec-1.0.0-linux-x86_64.zip
sudo mkdir -p /usr/local/bin
sudo mv shexec /usr/local/bin/shexec
sudo chmod +x /usr/local/bin/shexec
```

## Usage Instructions

> [!NOTE]
> Currently, `ShExec` uses the following models: `Gemini 1.0 Pro`, `Claude-3-opus-20240229` and `llama2` via Ollama (https://github.com/ollama/ollama), other models will be supported very soon !

To use the `shexec`, ensure you have a valid API KEY of the model you want to use (or Ollama installed if you prefer to work locally), then initiate the command alongside a textual description of your intended task. For example:

### Convert an image from JPG to PNG :
```shell
cd ~/Desktop && mkdir ShExecTest && cd ShExecTest
wget -O photo.jpg https://images.unsplash.com/photo-1512486130939-2c4f79935e4f
shexec "Convert the image photo.jpg to png"
```

> Upon initial use, you will be prompted to enter your model's API Key, then it will be saved to ~/.shexec.yml config file for future uses.

> Upon successful generation of the Shell script, it will be opened in a new terminal window. You will then be prompted to proceed with execution or abort the process. Press the 'r' key to execute the script, or any other key to abort.

> [!WARNING]
> It is **strongly advisable to carefully review the generated shell script** prior to execution to ensure it accurately fulfills your requirements.

## More Examples

### Perform a command based on a Regex description :
```shell
cd ~/Desktop/ShExecTest
touch Doc128_old.pdf
touch Doc123_old.pdf
shexec "Remove all PDF files that have a name starting with 'Doc' then an even index then end with '_old' (like: Doc124_old.pdf)"
```

### Create an HTML web page with some content (In Arabic) :
```shell
cd ~/Desktop/ShExecTest
shexec "قم بإعداد صفحة ويب تحتوي على ثلاث فقرات عن موضوع الحواسيب الكمومية بالعربية ثم قم بحفظها باسم الحواسيب_الكمومية، استعمل خطا عربيا جيدا من خطوط جوجل و لا تنس إعداد اتجاه النص من اليمين لليسار ، بعد ذلك افتحها في متصفح جوجل كروم"
```

### Create a simple JSON Flask REST API :
```shell
cd ~/Desktop/ShExecTest
shexec "Create a simple Flask API that will use the port 9090 and have one GET route (/api/v1/books) that will read the books (name, author) from a db.json file. Create an initial db.json file with 4 records. Put the code in a file app.py, then run it in the background and open a request example in chrome"
```

### Change Desktop wallpaper (in German) :
```shell
shexec "Holen Sie sich ein schönes Hintergrundbild von Unsplash und richten Sie es dann als Desktop-Hintergrund ein"
```

## Build Instructions

To build ShExec from source, run the following commands:

```shell
git clone https://github.com/YassineLafryhi/ShExec.git
cd ShExec
chmod +x build.sh
./build.sh
# Then you can move shexec to /usr/local/bin/shexec
```

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
[MIT License](https://choosealicense.com/licenses/mit)

