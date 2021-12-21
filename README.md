<!--

This source file is part of the JASS 2021 open source project

SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>

SPDX-License-Identifier: MIT

-->

# LIFXPostDiscoveryAction

An implementation of [Swift-NIO-LIFX](https://github.com/PSchmiedmayer/Swift-NIO-LIFX) that persists the discovered devices in a JSON file to be used as a Post Discovery Action for the [Apodini IoT Deployment Provider](https://github.com/Apodini/ApodiniIoTDeploymentProvider).

The Post Disovery Action automatically detects LIFX lamps and returns the number of LIFX lamps that can be found in the same network.

## Contributing
Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/Apodini/.github/blob/main/CONTRIBUTING.md) first.

## License
This project is licensed under the MIT License. See [License](https://github.com/Apodini/Apodini/blob/reuse/LICENSES/MIT.txt) for more information.

## Code of conduct
For our code of conduct see [Code of conduct](https://github.com/Apodini/.github/blob/main/CODE_OF_CONDUCT.md).