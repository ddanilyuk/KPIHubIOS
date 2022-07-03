# KPIHub

An iOS application for KPI students for schedule and campus.

This application works in cooperation with [server](https://github.com/ddanilyuk/KPIHubServer) written by me using Vapor. All detailed information about the server can be found in the README.md of server repository.

## This app provides

- Great design for schedule with convenient navigation
- CAMPUS studysheet integration
- Displaying elective disciplines
- Editing elective disciplines

##  Used technologies

- SwiftUI (every view in app written with it)
- [TCA](https://github.com/pointfreeco/swift-composable-architecture) (The Composable Architecture)
- [TCACoordinators](https://github.com/johnpatrickmorgan/TCACoordinators) (Convinent, but not perfect way for navigation in SwiftUI)
- [vapor-routing](https://github.com/pointfreeco/vapor-routing) (receiving api client for free from server library)

## Demo

![1](images/1.png)


![2](images/2.png)


![3](images/3.png)


## Plans

Feel free to write me if you have an feature idea or u want to implement something. All contacts in my profile

### Architecture

- [ ] Use new SwiftUI navigation
- [ ] Update TCA for async / await

### Rozklad

- [ ] Exams schedule
- [ ] Teachers schedule
- [ ] Other groups schedule
- [ ] Widget
- [ ] Check if rozklad changed

### Campus

- [ ] Campus exams ratings
- [ ] API integration (no parsing)

## How to build?

This application uses routing for api client from server written in swift. So, you need to somehow get this code. There are **two** variants

- Clone iOS app and Server app in to one folder
- Use SPM on iOS app to add library `Routes` from server repository