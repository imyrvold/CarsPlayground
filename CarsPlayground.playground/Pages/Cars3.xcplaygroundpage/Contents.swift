import UIKit
import Combine

var subscriptions: Set<AnyCancellable> = []

struct Car {
    let name: String
    let imageString: String?
}

struct CarWithImage {
    let name: String
    let image: UIImage?
}

final class CarClass {
    let myCars = [Car(name: "Tesla", imageString: "car"), Car(name: "Volvo", imageString: nil)]
    let delayCar = 4
    let delayImage = 1
    typealias CarAndImagePublisher = Publishers
        .Zip<AnyPublisher<Car, Error>, AnyPublisher<UIImage, Error>>

    func getVehicles() -> AnyPublisher<[CarWithImage], Error> {
        myCars.publisher
            .compactMap { car -> Car? in
                return car.imageString != nil ? car : nil
            }
            .flatMap(maxPublishers: .max(1)) { car -> CarAndImagePublisher in
                guard let imageString = car.imageString else { fatalError() }
                print(imageString)
                return Publishers.Zip(
                    Just(car).setFailureType(to: Error.self).eraseToAnyPublisher(),
                    self.getImage(imageString)
                )
            }
            .map { value -> CarWithImage in
                print(value.0.name)
                return CarWithImage(name: value.0.name, image: value.1)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func getImage(_ string: String) -> AnyPublisher<UIImage, Error> {
        Just(UIImage(systemName: string)!)
            .flatMap { image in
                Just(image).setFailureType(to: Error.self)
            }
            .delay(for: .seconds(delayImage), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

let carClass = CarClass()
carClass.getVehicles()
    .sink(receiveCompletion: { print($0)}) { cars in
        cars.forEach { car in
            let haveImage = car.image != nil
            let string = haveImage ? "and it have an image" : ""
            print("The car is", car.name, string)
        }
    }
    .store(in: &subscriptions)

//carClass.getImage("car")
//    .sink(receiveCompletion: { print($0)}) { image in
//        print("Got image", image)
//    }
//    .store(in: &subscriptions)
