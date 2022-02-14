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
    returns (bool)
    {
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
    
    int public message;

    constructor(int m) {
        message = m;
        typee = UserOutcomeTypes.UserNotFoundOutcome;
    }

}

contract Users {

    constructor() {
        int x = 0;
        // Get User
        UserOutcome result = getUser(1);

        // TODO - cast, based on type?

        // Handle result
        if (result.isType(UserOutcomeTypes.UserSuccessOutcome)) {
            x = UserSuccessOutcome(address(result)).result();
        } else 
        if (result.isType(UserOutcomeTypes.UserNotFoundOutcome)) {
            x = UserNotFoundOutcome(address(result)).message();
        }
    }

    function getUser(int id) public
    returns (UserOutcome result) {
        if (id < 0) {
            return new UserNotFoundOutcome(id);
        } else {
            return new UserSuccessOutcome(id);
        }
    }

}

contract Tickets {

    constructor() {

    }

}