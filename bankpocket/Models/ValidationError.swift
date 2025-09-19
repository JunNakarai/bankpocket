//
//  ValidationError.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/18.
//

import Foundation

// MARK: - Validation Errors

enum ValidationError: Error, LocalizedError, Equatable {
    case bankNameRequired
    case bankNameTooLong
    case branchNameRequired
    case branchNameTooLong
    case branchNumberRequired
    case branchNumberInvalidFormat
    case branchNumberRange
    case accountNumberRequired
    case accountNumberInvalidFormat
    case tagNameRequired
    case tagNameTooLong
    case tagColorInvalidFormat
    case duplicateAccount
    case duplicateTag
    case searchQueryTooLong
    case generalError(String)

    var errorDescription: String? {
        switch self {
        case .bankNameRequired:
            return "銀行名を入力してください"
        case .bankNameTooLong:
            return "銀行名は50文字以内で入力してください"
        case .branchNameRequired:
            return "支店名を入力してください"
        case .branchNameTooLong:
            return "支店名は50文字以内で入力してください"
        case .branchNumberRequired:
            return "支店番号を入力してください"
        case .branchNumberInvalidFormat:
            return "支店番号は3桁の数字で入力してください"
        case .branchNumberRange:
            return "支店番号は001-999の範囲で入力してください"
        case .accountNumberRequired:
            return "口座番号を入力してください"
        case .accountNumberInvalidFormat:
            return "口座番号は7桁の数字で入力してください"
        case .tagNameRequired:
            return "タグ名を入力してください"
        case .tagNameTooLong:
            return "タグ名は30文字以内で入力してください"
        case .tagColorInvalidFormat:
            return "色の形式が正しくありません（#RRGGBB形式で入力してください）"
        case .duplicateAccount:
            return "同じ銀行・支店・口座番号の組み合わせは既に登録されています"
        case .duplicateTag:
            return "同じ名前のタグが既に存在します"
        case .searchQueryTooLong:
            return "検索文字列が長すぎます（100文字以内）"
        case .generalError(let message):
            return message
        }
    }
}

// MARK: - Data Service Errors

enum DataError: Error, LocalizedError, Equatable {
    case databaseError
    case networkError
    case unknownError
    case operationCancelled
    case dataCorrupted
    case diskSpaceInsufficient

    var errorDescription: String? {
        switch self {
        case .databaseError:
            return "データベースエラーが発生しました"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .unknownError:
            return "予期しないエラーが発生しました"
        case .operationCancelled:
            return "操作がキャンセルされました"
        case .dataCorrupted:
            return "データが破損しています"
        case .diskSpaceInsufficient:
            return "ディスク容量が不足しています"
        }
    }
}