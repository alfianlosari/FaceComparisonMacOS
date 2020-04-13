# Face Rekognition SwiftUI macOS App

![Alt text](./promo.jpg?raw=true "Face Rekognition macOS App")

This project is a simple face recognition and comparison macOS App. It uses AWS Lambda and AWS Rekognition service built on top of nodeJS

## Functionality of the application

This application allows to perform face comparison between 2 faces passing source and target input images

## Requirements

- Xcode 11.4
- macOS 10.15

## Setup

- Please deploy the backend using your own AWS Credentials using this backend. https://github.com/alfianlosari/FaceComparisonServerlessAPI
- Replace the baseURL inside the `RekognitionService` using your own URL.
