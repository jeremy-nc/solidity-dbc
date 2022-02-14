//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

enum UserOutcomeTypes {
    UserNoOutcome,
    UserSuccessOutcome,
    UserNotFoundOutcome
}

contract UserOutcome {
    UserOutcomeTypes typee = UserOutcomeTypes.UserNoOutcome;
    
    function isType(UserOutcomeTypes t) public view
    returns (bool) {
        return typee == t;
    }
}

contract UserSuccessOutcome is UserOutcome {
    
    int public result;

    constructor(int r) {
        result = r;
        typee = UserOutcomeTypes.UserSuccessOutcome;
    }

}

contract UserNotFoundOutcome is UserOutcome {
    
    string public message;

    constructor(string memory m) {
        message = m;
        typee = UserOutcomeTypes.UserNotFoundOutcome;
    }

}

library UsersLib {
    struct User {
       string name;
    }
}

contract Users {

    constructor() { }

    function getUser(int id) public
    returns (UserOutcome result) {
        if (id < 0) {
            return new UserNotFoundOutcome("User not found for ID < 0");
        } else {
            return new UserSuccessOutcome(id);
        }
    }

}

contract Tickets {

    Users users = new Users();

    constructor() { }

    function getUserById(int id) public 
    returns (int userId) { // should be: string memory name, and all the attr of the user
        UserOutcome result = users.getUser(id);

        // TODO - cast, based on type?
        if (result.isType(UserOutcomeTypes.UserNotFoundOutcome)) revert(UserNotFoundOutcome(address(result)).message());

        // TODO - destructure result
        int user = UserSuccessOutcome(address(result)).result();
        return user;
    }

}