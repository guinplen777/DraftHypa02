//
//  Task.swift
//  Draft_Hypa_02
//
//  Created by mac on 20.10.16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import UIKit

struct Task {
    private(set) static var currentStep: Int = 0
    private static var numberOfStepsToChangeRange: Int = 5
    private static var rangeOfSummands = [1, 10]
    static var operation: Operation = .addition

    var question = "Question"
    var answer = [Int: String]()
    private var correctAnswer = Card.Item.unknown
    
    init() {
        updateCapacity()
        
        //Get minimum and maximum values of the 'rangeOfSummands' for the task's summands
        let min = Task.rangeOfSummands.min()!, max = Task.rangeOfSummands.max()!
        
        //Set to the summands random values from 'rangeOfSummands'
        var summand1 = getRandom(from: min, to: max)
        var summand2 = getRandom(from: min, to: max)
        
        switch Task.operation {
        case .addition:
            setAnswers(result: summand1 + summand2)
        
        case .subtraction:
            //Set 'summand2' a random value from range between 'minValueForRandom' and 'summand1'. So that 'summand2' always be biger than summand1 (to avoid negative result).
            summand2 = getRandom(from: min, to: summand1)
            setAnswers(result: summand1 - summand2)
        
        case .multiplication:
            setAnswers(result: summand1 * summand2)
            
        case .division:
            //Set 'summand2' a random value between 1 and 'summand1', for the first 5 questions. And random value between 1 and 'minValueForRandom' for follow-up questions. So that 'summand2' always be biger than summand1.
            summand2 = getRandom(from: 1, to: min == 1 ? summand1 : min)
            
            //Remove modulo from first 'summand' to get only integer result
            if (summand1 % summand2) != 0 {summand1 -= (summand1 % summand2)}
            setAnswers(result: summand1 / summand2)
        
        default:
            print("Task.Operation is not defined for this operation")
        }
        
        //Set question after summands was setted
        question = "\(summand1) \(Task.operation.rawValue) \(summand2)"
    }
    
    private func updateCapacity() {
        if Task.currentStep > Task.numberOfStepsToChangeRange {
            //Increase level of capaсity by double 'rangeOfSummands'
            Task.numberOfStepsToChangeRange += 5
            let max = Task.rangeOfSummands.max()!
            Task.rangeOfSummands = [max, max * 2]
        } else if Task.currentStep < 2 {
            //Reset to default values
            Task.numberOfStepsToChangeRange = 5
            Task.rangeOfSummands = [1, 10]
        }
        
        Task.currentStep += 1
    }
    
    static func resetCapacity() {
        Task.currentStep = 0
    }
    static func holdCapacity() {
        Task.currentStep -= 1
    }
    
    private mutating func setAnswers(result: Int) {
        //Create Set to store random unique values for answers
        var randomValues = Set<Int>()
        
        //Add result to the set
        randomValues.insert(result)

        //We create wrong answer by take random number from range ((result / 2) - (result * 1.5)). If we don't have enough numbers for cards (result < Card.count) we get random number from range ((result / 2) - (Card.count * 1.5))
        let numberOfAnswers = Card.count - 1
        
        let min = result/2
        let max = result < numberOfAnswers ? Int(Double(numberOfAnswers) * 1.5) : Int(Double(result) * 1.5)
        
        //Create random unique values for answers
        while randomValues.count < numberOfAnswers {
            randomValues.insert(getRandom(from: min, to: max))
        }
        
        //Setting random numbers to the answers. Answer's index starts from 1.
        for (index, value) in randomValues.enumerated() {
            answer[index + 1] = String(value)
            
            //Set correctAnswer
            if value == result { correctAnswer = .answer(index + 1) }
        }
    }
    
    func getLabel(for card: Card) -> String {
        switch card.item {
        case .question:
            return question
        case .answer(let number):
            return answer[number] ?? "no answer setted"
        default:
            return "getLabel() has not defined for this 'card.item': \(card.item)"
        }
    }
    
    func checkAnswer(touchedCard: Card.Item) -> Bool {
        return touchedCard == correctAnswer
    }
}

enum Operation: String {
    case addition = "+", subtraction = "-", multiplication = "x", division = "÷", unknown
    
    var color: UIColor {
        switch self {
        case .addition:
            return UIColor(red: 255/255, green: 185/255, blue: 33/255, alpha: 1)
        case .subtraction:
            return UIColor(red: 0/255, green: 212/255, blue: 2/255, alpha: 1)
        case .multiplication:
            return UIColor(red: 232/255, green: 14/255, blue: 2/255, alpha: 1)
        case .division:
            return UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        default:
            return UIColor.lightGray()
        }
    }
    
}

public func getRandom(from min: Int, to max: Int) -> Int {
    return Int(arc4random_uniform(UInt32((max - min)))) + min
}

extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
