//
//  PuzzleManager.swift
//  TrySarab
//
//  Created by Nada Abdullah on 16/09/1446 AH.
//

import Foundation

// 1) تعريف struct السؤال
struct QuizQuestion {
    let question: String
    let choices: [String]
    let correctAnswer: String
    let hint: String
}

// 2) مصفوفات الأسئلة
// الأسئلة السهلة (Easy)
let easyQuestions: [QuizQuestion] = [
    QuizQuestion(
        question: "Why was Al-Masmak Fortress a strategic location?",
        choices: [
            "It was used for gold storage",
            "It was a strong defensive fortress in central Riyadh",
            "It was the first airport in the Kingdom"
        ],
        correctAnswer: "It was a strong defensive fortress in central Riyadh",
        hint: "🏰 Controlling this fortress meant controlling the city!"
    ),
    QuizQuestion(
        question: "Who founded the First Saudi State?",
        choices: [
            "King Abdulaziz",
            "Imam Muhammad bin Saud",
            "Prince Turki bin Abdullah"
        ],
        correctAnswer: "Imam Muhammad bin Saud",
        hint: "🏛️ He established the state in Diriyah in 1727!"
    ),
    QuizQuestion(
        question: "What is the oldest market in Riyadh?",
        choices: [
            "Al-Zal Market",
            "Al-Alawi Market",
            "Souq Okaz"
        ],
        correctAnswer: "Al-Zal Market",
        hint: "🛍️ This market is famous for its antiques and traditional items!"
    )
]

// الأسئلة المتوسطة (Medium)
let mediumQuestions: [QuizQuestion] = [
    QuizQuestion(
        question: "What happened at Al-Masmak Fortress in 1902?",
        choices: [
            "The first Saudi oil well was discovered",
            "King Abdulaziz recaptured Riyadh from the Al-Rashid family",
            "The Ottoman army was defeated in a major battle"
        ],
        correctAnswer: "King Abdulaziz recaptured Riyadh from the Al-Rashid family",
        hint: "⚔️ This event marked the beginning of modern Saudi Arabia!"
    ),
    QuizQuestion(
        question: "Which of these places was a center of governance in the past?",
        choices: [
            "Diriyah",
            "Al-Khobar",
            "Jeddah Corniche"
        ],
        correctAnswer: "Diriyah",
        hint: "🏛️ It was the capital of the First Saudi State!"
    ),
    QuizQuestion(
        question: "Why were mud-brick walls common in old Riyadh palaces?",
        choices: [
            "They were cheaper to build",
            "They provided excellent insulation against heat and cold",
            "They prevented insects from entering"
        ],
        correctAnswer: "They provided excellent insulation against heat and cold",
        hint: "🏠 Mud walls kept houses cool in summer and warm in winter!"
    )
]

// الأسئلة الصعبة (Hard)
let hardQuestions: [QuizQuestion] = [
    QuizQuestion(
        question: "What is the most distinctive architectural feature of Al-Masmak Fortress?",
        choices: [
            "Its golden doors",
            "Its thick mud-brick towers",
            "Its underground tunnels"
        ],
        correctAnswer: "Its thick mud-brick towers",
        hint: "🏰 These towers made the fortress almost impossible to break into!"
    ),
    QuizQuestion(
        question: "What role did Diriyah play in Saudi history?",
        choices: [
            "It was a major oil production hub",
            "It was the first capital of the Saudi state",
            "It was an ancient Roman settlement"
        ],
        correctAnswer: "It was the first capital of the Saudi state",
        hint: "🏛️ Diriyah was the foundation of the Saudi Kingdom!"
    ),
    QuizQuestion(
        question: "How has Riyadh contributed to Saudi Arabia’s modern economy?",
        choices: [
            "By being the country’s main seaport",
            "By becoming the financial and business hub of the Kingdom",
            "By focusing on agriculture"
        ],
        correctAnswer: "By becoming the financial and business hub of the Kingdom",
        hint: "🏦 Riyadh hosts the largest banks and business centers!"
    )
]
