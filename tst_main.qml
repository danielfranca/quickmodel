import QtQuick 2.4
import QtTest 1.0

import "library/quickmodel.js" as QuickModel

TestCase {
    name: "quickModelTests"

    function test_create_database() {

    }

    function test_orm() {
        var quickModel = new QuickModel.QuickModel('testApp' + new Date(), '1.0');

        //Define object
        var User = quickModel.define('User', {
          username: quickModel.String('Username', {accept_null:false}),
          firstName: quickModel.String('First Name'),
          lastName: quickModel.String('Last Name'),
          birthday: quickModel.Date('Birthday'),
          height: quickModel.Float('Height'),
          weight: quickModel.Integer('Weight')
        });

        //Create object
        var user = User.create({username: "dfranca", firstName: "Daniel", lastName: "Franca"});
        //Filter objects
        var users = User.filter({username: "dfrancx"}).all();
        compare(users.length, 0);
        users = User.filter({username: "dfranca"}).all();
        compare(users.length, 1);
        user = users[0];

        compare(user.id, 1);

        //Save single object field change
        user.lastName = 'Frank';
        user.save();
        users = User.filter({lastName: "Frank"}).all();
        compare(users.length, 1);

        users = User.filter({username: "dfranca", firstName: "Danix"}).all();
        compare(users.length, 0);

        //Update user name and check if it was saved
        User.filter({username: "dfranca", firstName: "Daniel"}).update({firstName: "Danix"});
        users = User.filter({username: "dfranca", firstName: "Danix"}).all();
        compare(users.length, 1);

        //Delete user
        User.filter({username: "dfranca", firstName: "Danix"}).remove();
        users = User.filter({username: "dfranca"}).all();
        compare(users.length, 0);

        var user1 = User.create({username: "hsimpson", firstName: "Homer", lastName: "Simpson", birthday: new Date("1995-10-05"), height: 1.81});
        var user2 = User.create({username: "jdoe", firstName: "John", lastName: "Doe", birthday: new Date("1989-10-05"), height: 1.55});
        var user3 = User.create({username: "alock", firstName: "Adam", lastName: "Lock", height: 2.05, birthday: new Date("1991-10-25")});

        user = User.filter({username: "dfranca"}).update({height: 1.81});

        //Sort all users by height
        var usersOrdered = User.filter().order(['height']).all();

        compare(usersOrdered.length, 3);

        compare(usersOrdered[0].height, 1.55);
        compare(usersOrdered[0].username, "jdoe");

        compare(usersOrdered[1].height, 1.81);
        compare(usersOrdered[1].username, "hsimpson");

        compare(usersOrdered[2].height, 2.05);
        compare(usersOrdered[2].username, "alock");

        var user4 = User.create({username: "bsimpson", firstName: "Bart", lastName: "Simpson", birthday: new Date("2002-06-12"), height: 1.30});

        //Sort %simpsons% users by height desc
        var usersFiltered = User.filter({username__like: "simpson"}).order(['-height']).all();
        compare(usersFiltered.length, 2);

        compare(usersFiltered[0].firstName, "Homer");
        compare(usersFiltered[0].username, "hsimpson");

        compare(usersFiltered[1].firstName, "Bart");
        compare(usersFiltered[1].username, "bsimpson");

        var me = User.filter({username: "jdoe"}).get();
        me.lastName = "França";

        me.save();

        compare(User.filter({lastName: "França"}).all().length, 1);

        //Check users higher than 1.8m (to see how operators work)
        var tallUsers = User.filter({height__gt: 1.8}).order('height').all();
        compare(tallUsers.length, 2);
        compare(tallUsers[0].username, "hsimpson");
        compare(tallUsers[1].username, "alock");

    }
}

//Get/Set for lazy evaluation
//Test foreign key
//Test unique item
//Test not null
