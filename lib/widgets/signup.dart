import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'dart:typed_data';
import 'package:pointycastle/src/platform_check/platform_check.dart';



class SignUp extends StatefulWidget {

  @override
  State<SignUp> createState() => _SignUp();
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair( SecureRandom secureRandom, {int bitLength = 2048}) {
  // Create an RSA key generator and initialize it

  final keyGen = RSAKeyGenerator()..init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64), secureRandom));

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom exampleSecureRandom() {

  final secureRandom = SecureRandom('Fortuna')..seed(KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  return secureRandom;
}

parsePublicKeyFromPem(pemString) {
  Uint8List publicKeyDER = base64.decode(pemString);
  var asn1Parser = ASN1Parser(publicKeyDER);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  var publicKeyBitString = topLevelSeq.elements[1];

  var publicKeyAsn = ASN1Parser(publicKeyBitString.contentBytes()!);
  ASN1Sequence publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;
  var modulus = publicKeySeq.elements[0] as ASN1Integer;
  var exponent = publicKeySeq.elements[1] as ASN1Integer;

  RSAPublicKey rsaPublicKey = RSAPublicKey(
      modulus.valueAsBigInteger!,
      exponent.valueAsBigInteger!
  );

  return rsaPublicKey;
}

parsePrivateKeyFromPem(pemString) {
  Uint8List privateKeyDER = base64.decode(pemString);
  var asn1Parser = ASN1Parser(privateKeyDER);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  var version = topLevelSeq.elements[0];
  var algorithm = topLevelSeq.elements[1];
  var privateKey = topLevelSeq.elements[2];

  asn1Parser = ASN1Parser(privateKey.contentBytes()!);
  var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

  version = pkSeq.elements[0];
  var modulus = pkSeq.elements[1] as ASN1Integer;
  var publicExponent = pkSeq.elements[2] as ASN1Integer;
  var privateExponent = pkSeq.elements[3] as ASN1Integer;
  var p = pkSeq.elements[4] as ASN1Integer;
  var q = pkSeq.elements[5] as ASN1Integer;
  var exp1 = pkSeq.elements[6] as ASN1Integer;
  var exp2 = pkSeq.elements[7] as ASN1Integer;
  var co = pkSeq.elements[8] as ASN1Integer;

  RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
      modulus.valueAsBigInteger!,
      privateExponent.valueAsBigInteger!,
      p.valueAsBigInteger,
      q.valueAsBigInteger
  );

  return rsaPrivateKey;
}

encodePublicKeyToPem(RSAPublicKey publicKey) {
  var algorithmSeq = ASN1Sequence();
  var algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  var publicKeySeq = ASN1Sequence();
  publicKeySeq.add(ASN1Integer(publicKey.modulus!));
  publicKeySeq.add(ASN1Integer(publicKey.exponent!));
  var publicKeySeqBitString = ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqBitString);
  var dataBase64 = base64.encode(topLevelSeq.encodedBytes);
  return dataBase64;
}

encodePrivateKeyToPem(RSAPrivateKey privateKey) {
  var version = ASN1Integer(BigInt.from(0));

  var algorithmSeq = ASN1Sequence();
  var algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  var privateKeySeq = ASN1Sequence();
  var modulus = ASN1Integer(privateKey.n!);
  var publicExponent = ASN1Integer(BigInt.parse('65537'));
  var privateExponent = ASN1Integer(privateKey.d!);
  var p = ASN1Integer(privateKey.p!);
  var q = ASN1Integer(privateKey.q!);
  var dP = privateKey.d! % (privateKey.p! - BigInt.from(1));
  var exp1 = ASN1Integer(dP);
  var dQ = privateKey.d! % (privateKey.q! - BigInt.from(1));
  var exp2 = ASN1Integer(dQ);
  var iQ = privateKey.q!.modInverse(privateKey.p!);
  var co = ASN1Integer(iQ);

  privateKeySeq.add(version);
  privateKeySeq.add(modulus);
  privateKeySeq.add(publicExponent);
  privateKeySeq.add(privateExponent);
  privateKeySeq.add(p);
  privateKeySeq.add(q);
  privateKeySeq.add(exp1);
  privateKeySeq.add(exp2);
  privateKeySeq.add(co);
  var publicKeySeqOctetString = ASN1OctetString(Uint8List.fromList(privateKeySeq.encodedBytes));

  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(version);
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqOctetString);
  var dataBase64 = base64.encode(topLevelSeq.encodedBytes);
  return dataBase64;
}

Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _processInBlocks(decryptor, cipherText);
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}

class _SignUp extends State<SignUp> {
  int yearNow = DateTime.now().year;
  int monthNow = DateTime.now().month;
  int dayNow = DateTime.now().day;
  late DateTime dob;
  TextEditingController pseudo = TextEditingController();
  TextEditingController mail = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPdw = TextEditingController();
  UserUseCase activityUseCase = UserUseCase();
  final _formKey = GlobalKey<FormState>();
  late Gender _gender;
  bool error = false;
  int? val = 1;

  validForm()async
  {
    String message = "Bonjour";
    print("bonjour");
    final pair = generateRSAkeyPair(exampleSecureRandom());
    final public = pair.publicKey;
    final private = pair.privateKey;

    final pemPublicKey = encodePublicKeyToPem(public);
    print("ma clé publique = $pemPublicKey");
    final pemPrivateKey = encodePrivateKeyToPem(private);
    print("ma clé privée = $pemPrivateKey");
    final pubKey = parsePublicKeyFromPem(pemPublicKey);
    final privKey = parsePrivateKeyFromPem(pemPrivateKey);

    List<int> list = message.codeUnits;
    Uint8List data = Uint8List.fromList(list);

    final encryptData = rsaEncrypt(pubKey, data);
    print(encryptData);
    final decryptData = rsaDecrypt(privKey, encryptData);
    String result = Utf8Decoder().convert(decryptData);
    print(result);



    if (_formKey.currentState!.validate()){
      if(val == 1){
        _gender = Gender.male;
      }else{
        _gender= Gender.female;
      }
      User user = User(username:pseudo.text,mail:mail.text, role:"USER", gender:_gender, birthday: dob);
      activityUseCase.add(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end:
              Alignment(0.0, 0.0), // 10% of the width, so there are ten blinds.
              colors: <Color>[
                Color(0xff50861d),
                Color(0xff60e00f)
              ],),),
          child: Center(
            child: SingleChildScrollView(
              child : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Column(
                      children:
                      [
                        Text('GO TOGETHER', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),),
                        Container(height: 50),
                        TextFormField(
                            controller: pseudo,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'pseudo',

                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un pseudo';
                              }
                              return null;
                            }
                        ),
                        TextFormField(
                            controller: mail,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'mail',

                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mail';
                              }
                              return null;
                            }
                        ),
                        TextFormField(
                            controller: password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'mot de passe',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              return null;
                            }
                        ),
                        Container(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sexe :'),
                            Row(
                              children: [
                                Text('homme'),
                                Radio(
                                  value: 1,
                                  groupValue: val,
                                  onChanged: (int? value) {
                                    setState(() {
                                      val = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('femme'),
                                Radio(
                                  value: 2,
                                  groupValue: val,
                                  onChanged: (int? value) {
                                    setState(() {
                                      val = value;
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date de naissance :'),
                            ElevatedButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1800),
                                      maxTime: DateTime(yearNow, monthNow, dayNow),
                                      onConfirm: (date) {
                                        setState(() {
                                          dob = date;
                                        });
                                      }, currentTime: DateTime.now(), locale: LocaleType.fr);
                                },
                                child: const Icon(Icons.calendar_today_outlined)/*Text(
                  "Choisir une date pour l'évènement",
                )*/
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child:
                          TextFormField(
                              obscureText: true,
                              controller: confirmPdw,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Confirmation de mot de passe',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez confirmer le mot de passe';
                                } else if(confirmPdw.text!=password.text){
                                  return 'les mots de passes ne sont pas identiques';
                                }
                                return null;
                              }
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child:
                          ElevatedButton(
                            onPressed: (()=>validForm()),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      )
    );
  }
}
