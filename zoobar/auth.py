from zoodb import *
from debug import *

import hashlib
import random

def newtoken(db, cred):
    hashinput = "%s%.10f" % (cred.password, random.random())
    cred.token = hashlib.md5(hashinput).hexdigest()
    db.commit()
    return cred.token

def login(username, password):
    persondb = person_setup()
    person = persondb.query(Person).get(username)
    if not person:
        return None

    creddb = cred_setup()
    cred = creddb.query(Cred).get(username)
    if not cred:
        return None

    if cred.password == password:
        return newtoken(creddb, cred)
    else:
        return None

def register(username, password):
    persondb = person_setup()
    person = persondb.query(Person).get(username)
    if person:
        return None

    newperson = Person()
    newperson.username = username
    persondb.add(newperson)

    creddb = cred_setup()
    newcred = Cred()
    newcred.username = username
    newcred.password = password
    creddb.add(newcred)

    creddb.commit()
    persondb.commit()
    return newtoken(creddb, newcred)

def check_token(username, token):
    creddb = cred_setup()
    cred = creddb.query(Cred).get(username)
    if cred and cred.token == token:
        return True
    else:
        return False

