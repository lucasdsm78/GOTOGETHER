import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'dart:typed_data';
import 'package:pointycastle/src/platform_check/platform_check.dart';



class SignUp extends StatefulWidget {

  @override
  State<SignUp> createState() => _SignUpState();
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


// fonction qui permet de créer la signature

Uint8List rsaSign(RSAPrivateKey privateKey, Uint8List dataToSign) {

  final signer = RSASigner(SHA256Digest(), '0609608648016503040201');

  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // true=sign

  final sig = signer.generateSignature(dataToSign);

  return sig.bytes;
}

// fonction qui permet de verifier la signature

bool rsaVerify(RSAPublicKey publicKey, Uint8List signedData, Uint8List signature) {
  final sig = RSASignature(signature);

  final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');

  verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey)); // false=verify

  try {
    return verifier.verifySignature(signedData, sig);
  } on ArgumentError {
    return false; // for Pointy Castle 1.0.2 when signature has been modified
  }
}


class _SignUpState extends State<SignUp> {
  final LocalStorage storage = LocalStorage('go_together_app');
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
    // final pair = generateRSAkeyPair(exampleSecureRandom());
    // final public = pair.publicKey;
    // final private = pair.privateKey;

    // final pemPublicKey = encodePublicKeyToPem(public);
    // print("ma clé publique = $pemPublicKey");
    // final pemPrivateKey = encodePrivateKeyToPem(private);
    // print("ma clé privée = $pemPrivateKey");
    // final pubKey = parsePublicKeyFromPem(pemPublicKey);
    // final privKey = parsePrivateKeyFromPem(pemPrivateKey);

    // final pubKeyAlice = parsePublicKeyFromPem("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsDX+okk4FcdaFD0nvM7uZGdrQTyL2u2PdRk8mGa1BgpqgaoP8s7JZsgejVEaHxKGtCEsOuLSjZ/4veNqwuvwP1L3DAo02udJpqDRCQ4hmhS2ulDvU2qt0WHM1tqOyofvizDfFVBaDbGu+36tOHrk8RBh6KvikgCA1V//sDYTtzazmCfLicTx2AKKoXbML22Lh7b9Nlhy/cVlhiGsf6fJ5Nc+juZch2u2g5E0fzvqHLKGI5CTNB2sJTwl/yeJ3Os3pf4uWjMwbVFjB/7LvHZMMuWCGSStQzpEHC6/jeQcegUWQGC42kYBpextqwJmGq0LzOO/c3UhGwXAtxXVclD38QIDAQAB");
    final privKeyAlice = parsePrivateKeyFromPem("MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCwNf6iSTgVx1oUPSe8zu5kZ2tBPIva7Y91GTyYZrUGCmqBqg/yzslmyB6NURofEoa0ISw64tKNn/i942rC6/A/UvcMCjTa50mmoNEJDiGaFLa6UO9Taq3RYczW2o7Kh++LMN8VUFoNsa77fq04euTxEGHoq+KSAIDVX/+wNhO3NrOYJ8uJxPHYAoqhdswvbYuHtv02WHL9xWWGIax/p8nk1z6O5lyHa7aDkTR/O+ocsoYjkJM0HawlPCX/J4nc6zel/i5aMzBtUWMH/su8dkwy5YIZJK1DOkQcLr+N5Bx6BRZAYLjaRgGl7G2rAmYarQvM479zdSEbBcC3FdVyUPfxAgMBAAECggEAPwxCvJxIFfrLLzymcDb2MzSRurjILaAcWUCbXsg48x1c+GH57N2yUDVAQT4Ig5+kVOUdp0ArKANaA89QDshOoMm1nTg1qzFgN9+Ii53jxfatXsLAru8XnDhLC4EN4Ed9HSdyWnTyk73EpzWvEutd6Sb8cTy3B5hogHAl0022BjJSNezpMc6QfKhEkSlYuooKM8+QzMa9uPTfBvYGIPsM0doUZ9Z943a0Qk6ta9t2BEtDVjGKCJq9z4Gs6pII9vDWuoz9l3coexd8p0FYt4E95pURftBrdURMwhLvwG6u0K3FTiZOrX3FR9fyjA2TxIPDrmeILDuXkcg72kNhmwW2VQKBgQDwAosZ7ksEfqcte4lAHM8Chzdy9pgGUJ+d5g4jTR1tTOCFtcz2c4pmKOICD9//9D9csD3E3Jz3XNt8bwwwkEu8OWoDRHpxOGnwLeRjlnclEDPamrYg8nz2h+7kcYnwYSzzyongiPHb6K+7fM2PshSRVyS/qpTgpFbzoo4rdmtnqwKBgQC781X7Jj+zsTuliUEp/ix2iA+b7mw2v4ad0yLRtcwea6xfU7ZvskBGknvB8renek4Gd2hreRvTYZjDBPdcCjF7oJeHfrG/3rDBdZv8FGBpJ4fZ3hyv6MQBiTRXDQqarK4aZ3nt/aG3pzx5MS96pcgFZxe9WvwjA/oO35bfjQGS0wKBgGKnCPodoqQ0Uw806hN6Q/SsE7Sje5WM6i8C8ui7t87HfLo5IghjMY4QW+WxFMemY6z7nEggzjw25Nje5EnJ5fd2OgchzJphL9pTYr80h8CqSkYetaIRSiAje6RWrvYpW0rSA55Ra+iSWjlccToRXrbm9On7ebpkkoEOXhWrVTaFAoGBAInNoSXyZlRmxxfY6blTTeBeZCttBVSi2p2O94GQ7KcFRS3jn+iHZg8YSbrrLfKSfvDIzfu2oUs7zJh4ZLDMHHnLRi6nGsZWDXzasVKC0ilnPXjlHF1xqXyCz6hfvH2pzEE5yzFOfCq+aF1nTat8L4qeis5gDmvR956+Gs2vgg7XAoGAQqFz8AZzoYRU6qt9hCckuFZB1FCkTzbiAw5gjY3prOXuSd2iDHG1cueboYcPyC45hVoBzsjWigfXavG9RbOvqhEZuwKAB9GgLch70nuDenF4gJFbz/O6Q0KWRxfWFMZ3TY8mfeEdxQVbo9hYRgXPl2GizZTklezPvxuubrmKQJ8=");

    storage.setItem('pubKey', "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsDX+okk4FcdaFD0nvM7uZGdrQTyL2u2PdRk8mGa1BgpqgaoP8s7JZsgejVEaHxKGtCEsOuLSjZ/4veNqwuvwP1L3DAo02udJpqDRCQ4hmhS2ulDvU2qt0WHM1tqOyofvizDfFVBaDbGu+36tOHrk8RBh6KvikgCA1V//sDYTtzazmCfLicTx2AKKoXbML22Lh7b9Nlhy/cVlhiGsf6fJ5Nc+juZch2u2g5E0fzvqHLKGI5CTNB2sJTwl/yeJ3Os3pf4uWjMwbVFjB/7LvHZMMuWCGSStQzpEHC6/jeQcegUWQGC42kYBpextqwJmGq0LzOO/c3UhGwXAtxXVclD38QIDAQAB");
    String test = storage.getItem('pubKey');

    print(test);

    final pubKeyBob = parsePublicKeyFromPem("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1h6yJbSFD2pnbOgzj6Oh7L0zlFS9ePopaCKhPmIG7Bk7sXk2IN3BsP8fv0DbTJCePL9xUQcvMmzMP4YfCKLo/NnyC3H3aF5KTvYzxOY6NZ6BiUkEYCdTfgMNszT6v6MriWfqCeakRCy0JVoKpO32DuuefsrMUKnKg+LatMc3DW1FejSzckbzt9qdtbOFANAHoTvtwDda2qyzO+VKhUw3vqpSwj3gNTiFiDJTs/3JBXVN5+r3q3X9AM6iVVOxxcyIYoNkbdqiP0PHex6DCi9yyCam5r3egfHEfY2pQCEbgiYEvQX0VUZXdktBK3SPZYPgGfpOOu3ZFL3T72xit/DrgwIDAQAB");
    final privKeyBob = parsePrivateKeyFromPem("MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDWHrIltIUPamds6DOPo6HsvTOUVL14+iloIqE+YgbsGTuxeTYg3cGw/x+/QNtMkJ48v3FRBy8ybMw/hh8Iouj82fILcfdoXkpO9jPE5jo1noGJSQRgJ1N+Aw2zNPq/oyuJZ+oJ5qRELLQlWgqk7fYO655+ysxQqcqD4tq0xzcNbUV6NLNyRvO32p21s4UA0AehO+3AN1rarLM75UqFTDe+qlLCPeA1OIWIMlOz/ckFdU3n6verdf0AzqJVU7HFzIhig2Rt2qI/Q8d7HoMKL3LIJqbmvd6B8cR9jalAIRuCJgS9BfRVRld2S0ErdI9lg+AZ+k467dkUvdPvbGK38OuDAgMBAAECggEAbOGjGYVYfGRRP5I8VfiRqL71caI9zzz2vVuOvxg+COUz86V9nuzlR8oULL8gRSjtLlrzlo6es3ebzVm4gj3FWH7DlIpZkxsPkmOkI6YnR4jYuiUFMpgM3vFSkCSKtdSVmQPcgThlo71PxgapjwDqtN+f8z3Q89vDfZloObFsD0jpadJ3j6c1hDKuMaS/SiRIWtKZ2M/IqHUH56LuHdEWRVlijBex0iN4ZMXvUtqwJzy+Q0MYpU6clGEh5bPU7jpG3HLd00gVNNwUOwLVAF3a1v3dP6xITxRiNo/grrkW10j+qooJBzNmS9ooDH4XP7jWQm2QthbqNTMvnFAOSS2kIQKBgQDxNRv6YBz+CVYo1r6DToj9+mJi7ljheoiXSufKdCGiOuBP4HQM2Q32hg9OUBX0AUKssOuYX5hc0Y4mR/TRKTg2XJoH4YCTqYIwSA/GRCNcRsR9nFMvBE2Z3NbhmKNE9ZLPpc/gQvWHI6lryTbm+WW81Rur0iF1GwDFDVxRy3nKewKBgQDjQFHJiiFwfFq978nAZSwGar2q/sdu4WkyC00hbEMOptXrLihrKreLVao7wVSJHzMgDgsv+VrOsoDiwACx6/+vy6vMYI0uu7mASMXyE0mnsr2WQFeK+hg+BkPl+hop8EzMIbL0jUAKcrz3TRWbiK12f4NWIgG+yaAD3xHIPtQ4mQKBgCcBdaLJhCa4j8xO3cQSISkhImPpM0pTLF9653zfxsibSMbh/yJMv2tMRpFddg9dXNDcU1zyqIrqAFjEbhyc09BGrUn093vpf3obTSG8xxMXBpNhgjoqMfpdsgoNSunN5I3bvIABk/7kj3M0uMIlNoSQ2caxVmO/mCJFhNZdVzadAoGAEz6pLnYiKtJ9JMSfw0lOFyUG9uoonX09WV2XpJL0gtMiHo6EIb82V/hjODhBHnOj8rz9uYxWYla/j3RPGsIvnwWSgPZUPnbrWK/RA5UakbcTUxwTzdMsJmSFb35kpNSSzF62NvuXRss8sXy3rbo/Zl+aEbtDhpKwmGNVsC2R71ECgYEAmbTDNXxOrYG+i/VW89VBEpP9QqkU1CgTH85CCHyNXam+MzLGljfgiBlmZDuY4NThJdLLmg2rOu+OuO/lOdwHe80B7yh2IaiGfOkyqwDx+cUZFoza77Rc2LsW0YRvMw0VHL0gt/R6kGhq6eggKeKJWa1s4uAMHZLifDRSqNyenPs=");

    List<int> list = message.codeUnits;
    Uint8List data = Uint8List.fromList(list);



    final pubKeyAlice = parsePublicKeyFromPem(test);
    final encryptData = rsaEncrypt(pubKeyBob, data);
    final signature = rsaSign(privKeyAlice, encryptData); // creation de la signature à partir de le message cryptée
    final decryptData = rsaDecrypt(privKeyBob, encryptData); // décrypte le message
    String result = Utf8Decoder().convert(decryptData);
    String cryptMessageSigned = "$result $signature"; // crée le message crypté avec la signature qui sera split avec final splitted = cryptMessageSigned.split(' ');"
    print(rsaVerify(pubKeyAlice, encryptData ,signature));// envoie true si la signature provient de l'emmeteur


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
