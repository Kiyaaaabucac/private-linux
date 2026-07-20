pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io


Singleton {

    id: root


    property string distro: ""
    property string kernel: ""
    property string cpu: ""
    property string gpu: ""
    property string ram: ""


    Process {

        id: info


        command: [
            "bash",
            "-c",
            "echo DISTRO=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"'); " +
            "echo KERNEL=$(uname -r); " +
            "echo CPU=$(lscpu | grep 'Model name' | cut -d: -f2 | xargs); " +
            "echo GPU=$(lspci | grep VGA | cut -d: -f3 | xargs); " +
            "echo RAM=$(free -h | awk '/Mem:/ {print $3 \"/\" $2}')"
        ]


        running: true


        stdout: StdioCollector {

            onStreamFinished: {

                let lines = text.split("\n")


                for (let line of lines) {

                    let data = line.split("=")


                    if (data.length < 2)
                        continue


                        let key = data[0]
                        let value = data.slice(1).join("=")


                        switch(key) {

                            case "DISTRO":
                                root.distro = value
                                break

                            case "KERNEL":
                                root.kernel = value
                                break

                            case "CPU":
                                root.cpu = value
                                break

                            case "GPU":
                                root.gpu = value
                                break

                            case "RAM":
                                root.ram = value
                                break

                        }

                }

            }

        }

    }

}
