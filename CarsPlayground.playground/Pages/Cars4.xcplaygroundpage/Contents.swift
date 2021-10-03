import UIKit
import Combine

struct Car {
    let name: String
    let imageString: String?
}

struct CarWithImage {
    let name: String
    let image: UIImage?
}

final class CarClass {
    let myCars = [Car(name: "Tesla", imageString: "bolt.car"), Car(name: "Volvo", imageString: nil)]
    let delayCar = 4
    let delayImage = 6
    
    func getVehicles() -> AnyPublisher<[CarWithImage], Error> {
        myCars.publisher
            .flatMap { car in
                self.getImage(car.imageString)
                    .flatMap { image -> Just<CarWithImage> in
                        guard let image = image else { return Just(CarWithImage(name: car.name, image: nil)) }
                        return Just(CarWithImage(name: car.name, image: image))
                    }
            }
            .collect()
            .flatMap { cars in
                cars.publisher.setFailureType(to: Error.self)
            }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getImage(_ string: String?) -> AnyPublisher<UIImage?, Error> {
        guard let imageString = string else { return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher() }
        return Just(UIImage(systemName: imageString))
            .flatMap { image in
                Just(image).setFailureType(to: Error.self)
            }
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

//carClass.getImage("car")
//    .sink(receiveCompletion: { print($0)}) { image in
//        print("Got image", image)
//    }
