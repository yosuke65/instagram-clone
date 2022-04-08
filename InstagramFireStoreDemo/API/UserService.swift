//
//  UserService.swift
//  InstagramFireStoreDemo
//
//  Created by Yosuke Sakurai on 4/6/22.
//

import Firebase

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    static func fetchUser(completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            completion(users)
            
        }
    }
    
    static func followUser(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let curretUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(curretUid).collection("user-following").document(uid)
            .setData([:]) { error in
                COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(curretUid)
                    .setData([:], completion: completion)
            }
    }
    
    static func unfollowUser(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let curretUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(curretUid).collection("user-following")
            .document(uid).delete() { error in
                COLLECTION_FOLLOWERS.document(uid).collection("user-followers")
                    .document(curretUid).delete(completion: completion)
            }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void ) {
        guard let curretUid = Auth.auth().currentUser?.uid else { return }
        
        let ref = COLLECTION_FOLLOWING.document(curretUid).collection("user-following").document(uid).getDocument
        { (snapshot, error) in
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { (snapshot, error) in
            let followers = snapshot?.documents.count ?? 0
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { (snapshot, error) in
                let following = snapshot?.documents.count ?? 0
                completion(UserStats(followers: followers, following: following))
            }
        }
    }
}
