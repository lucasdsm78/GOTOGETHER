
import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'dart:typed_data';
import 'package:pointycastle/src/platform_check/platform_check.dart';

import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

//region helpers keys pair / encryption
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

RSAPublicKey parsePublicKeyFromPem(pemString) {
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

RSAPrivateKey parsePrivateKeyFromPem(pemString) {
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

String encodePublicKeyToPem(RSAPublicKey publicKey) {
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

String encodePrivateKeyToPem(RSAPrivateKey privateKey) {
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
//endregion


class AsymetricKeyGenerator{
  final LocalStorage storage = LocalStorage('go_together_app');
  final indexPrivate = "privateKey";
  final indexPublic = "pubKey";
  var id = "1";

  setId(String newId){
    id = newId;
  }

  getPubKeyFromStorage(){
    if(storage.getItem("$indexPublic$id") == null){
      generateKey();
    }
    return storage.getItem("$indexPublic$id");
  }
  setPubKeyFromStorage(String pubKey){
    storage.setItem("$indexPublic$id", pubKey);
  }
  getPrivateKeyFromStorage(){
    if(storage.getItem("$indexPrivate$id") == null){
      generateKey();
    }
    return storage.getItem("$indexPrivate$id");
  }
  setPrivateKeyFromStorage(String privateKey){
    storage.setItem("$indexPrivate$id", privateKey);
  }

  generateKey({bool isTestMode = false}){
    if(isTestMode){
      if(id=="1") {
        setPubKeyFromStorage("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsDX+okk4FcdaFD0nvM7uZGdrQTyL2u2PdRk8mGa1BgpqgaoP8s7JZsgejVEaHxKGtCEsOuLSjZ/4veNqwuvwP1L3DAo02udJpqDRCQ4hmhS2ulDvU2qt0WHM1tqOyofvizDfFVBaDbGu+36tOHrk8RBh6KvikgCA1V//sDYTtzazmCfLicTx2AKKoXbML22Lh7b9Nlhy/cVlhiGsf6fJ5Nc+juZch2u2g5E0fzvqHLKGI5CTNB2sJTwl/yeJ3Os3pf4uWjMwbVFjB/7LvHZMMuWCGSStQzpEHC6/jeQcegUWQGC42kYBpextqwJmGq0LzOO/c3UhGwXAtxXVclD38QIDAQAB");
        setPrivateKeyFromStorage("MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCwNf6iSTgVx1oUPSe8zu5kZ2tBPIva7Y91GTyYZrUGCmqBqg/yzslmyB6NURofEoa0ISw64tKNn/i942rC6/A/UvcMCjTa50mmoNEJDiGaFLa6UO9Taq3RYczW2o7Kh++LMN8VUFoNsa77fq04euTxEGHoq+KSAIDVX/+wNhO3NrOYJ8uJxPHYAoqhdswvbYuHtv02WHL9xWWGIax/p8nk1z6O5lyHa7aDkTR/O+ocsoYjkJM0HawlPCX/J4nc6zel/i5aMzBtUWMH/su8dkwy5YIZJK1DOkQcLr+N5Bx6BRZAYLjaRgGl7G2rAmYarQvM479zdSEbBcC3FdVyUPfxAgMBAAECggEAPwxCvJxIFfrLLzymcDb2MzSRurjILaAcWUCbXsg48x1c+GH57N2yUDVAQT4Ig5+kVOUdp0ArKANaA89QDshOoMm1nTg1qzFgN9+Ii53jxfatXsLAru8XnDhLC4EN4Ed9HSdyWnTyk73EpzWvEutd6Sb8cTy3B5hogHAl0022BjJSNezpMc6QfKhEkSlYuooKM8+QzMa9uPTfBvYGIPsM0doUZ9Z943a0Qk6ta9t2BEtDVjGKCJq9z4Gs6pII9vDWuoz9l3coexd8p0FYt4E95pURftBrdURMwhLvwG6u0K3FTiZOrX3FR9fyjA2TxIPDrmeILDuXkcg72kNhmwW2VQKBgQDwAosZ7ksEfqcte4lAHM8Chzdy9pgGUJ+d5g4jTR1tTOCFtcz2c4pmKOICD9//9D9csD3E3Jz3XNt8bwwwkEu8OWoDRHpxOGnwLeRjlnclEDPamrYg8nz2h+7kcYnwYSzzyongiPHb6K+7fM2PshSRVyS/qpTgpFbzoo4rdmtnqwKBgQC781X7Jj+zsTuliUEp/ix2iA+b7mw2v4ad0yLRtcwea6xfU7ZvskBGknvB8renek4Gd2hreRvTYZjDBPdcCjF7oJeHfrG/3rDBdZv8FGBpJ4fZ3hyv6MQBiTRXDQqarK4aZ3nt/aG3pzx5MS96pcgFZxe9WvwjA/oO35bfjQGS0wKBgGKnCPodoqQ0Uw806hN6Q/SsE7Sje5WM6i8C8ui7t87HfLo5IghjMY4QW+WxFMemY6z7nEggzjw25Nje5EnJ5fd2OgchzJphL9pTYr80h8CqSkYetaIRSiAje6RWrvYpW0rSA55Ra+iSWjlccToRXrbm9On7ebpkkoEOXhWrVTaFAoGBAInNoSXyZlRmxxfY6blTTeBeZCttBVSi2p2O94GQ7KcFRS3jn+iHZg8YSbrrLfKSfvDIzfu2oUs7zJh4ZLDMHHnLRi6nGsZWDXzasVKC0ilnPXjlHF1xqXyCz6hfvH2pzEE5yzFOfCq+aF1nTat8L4qeis5gDmvR956+Gs2vgg7XAoGAQqFz8AZzoYRU6qt9hCckuFZB1FCkTzbiAw5gjY3prOXuSd2iDHG1cueboYcPyC45hVoBzsjWigfXavG9RbOvqhEZuwKAB9GgLch70nuDenF4gJFbz/O6Q0KWRxfWFMZ3TY8mfeEdxQVbo9hYRgXPl2GizZTklezPvxuubrmKQJ8=");
      }
      else if(id=="2"){
        setPubKeyFromStorage("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoUDPEhvS47YFCX83RVklj+M1i2t7JGbqAx6or1VpNp+1Mh+p2Sr4kryvJdJuKB5JN/l8L/3bo8QRO5/y2BiBqRZ9QL4+C7THlItFo5Y29jvc/8Mjm9CosP+3Xdd1XsYiyD5SP3zVHXEmfButgzFaFhhvdCvvopQ3NE6I2Xdz3nCuHdY8PNDp8Gt8jqzydGAb9tsobUlgfc+R7t8ho8OgzEHTzurHj+7hGES4gG0ggiLzt5TvP714jnJMElroyuScdgRF+2vN1QDn1KTH/FW4+bkVVr3KrDqBs5vpaB6qx+zID9Y/iDN1HurMLvefrHm/EcH+qnkpH8zaxVYV5YctcQIDAQAB");
        setPrivateKeyFromStorage("MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQChQM8SG9LjtgUJfzdFWSWP4zWLa3skZuoDHqivVWk2n7UyH6nZKviSvK8l0m4oHkk3+Xwv/dujxBE7n/LYGIGpFn1Avj4LtMeUi0Wjljb2O9z/wyOb0Kiw/7dd13VexiLIPlI/fNUdcSZ8G62DMVoWGG90K++ilDc0TojZd3PecK4d1jw80Onwa3yOrPJ0YBv22yhtSWB9z5Hu3yGjw6DMQdPO6seP7uEYRLiAbSCCIvO3lO8/vXiOckwSWujK5Jx2BEX7a83VAOfUpMf8Vbj5uRVWvcqsOoGzm+loHqrH7MgP1j+IM3Ue6swu95+seb8Rwf6qeSkfzNrFVhXlhy1xAgMBAAECggEBAJCGN5ExYtg4YVdbr7v15FaL+4eTs3Cy1HYrWmCbGoucpJfiDSbY/qT1e71YVuaaDmGet5GD4wFqT0+zUcIgZMWZpHUMjSuMwXv/P1EY5vXWPYL18MpMP4U0C7KN02I4DyCNysWgKpoSub1uSRtWdjlreSkT39lFIh09biYKi80GnA5nPgnKpgURobETtGtyNSVd+avGzxLKULtIlGo6vHiDv+/huPH8yId0GH02aizeTECxriQx5XWzF8l21UNVxer7EbZCTyW95l2KbhA495ELaGdDA8xbA0PQx+UqI8mHwv7+to+wKDOW1aNHTy01tMbgTsxFCfWqdL7e9sSTSYkCgYEA7lLgqKtwfDT5iaba7Ph4MjTTBox/+7PMlE0HTY3Zldjqn23IrWz8UkEBjE6ozoPWictzqpOFXf97Segq6a+dX8mXgmcaaEfL0FUNhdH+kG6tJq+e6KGnnIM4j2VdrD7kyTJXREDUsiG65pMWakXyzPnqEFAi+gvN7ABrKprXFV8CgYEArTaR1pyt4IpuykPsZDzqnxWD4xxCKxGsk2LroBZNLKlD8FR4KIC7OyI0pGZ9dxGIvKparmyI89CJutD+6yCQlRVei0gDGO6Ku46vRk2PX4Tn5CV0NLRK6iUrZolvYDuy6OnQXv7sOZ2GmuOa6BlI6vpQvKOgjbZDfM9y23JkXy8CgYBz8Rfglr77fh4kDGuXO23mJvK+zd15i0gsoai63xaKouPJufQWAt5h+cQSCTZweY0GrlbQFkKcryzAkNVHqKrsLbuqshQTxVHvQWF5x+aLR3yvRGMPk41iRChhApRmtpZBF1+DEfMn0ecGQ2p1OyBa/f4T/5h0gwekF7QLHxciCwKBgQCnnjMq95vbuprT6T8NEVYKdIuYb3QosYXLauKRnIM6QOKZ42QT7d9Briw7G2M2oiUsTb5LJISzTI671huZ9X10h6ViK2Gz8sMWFVHQOqYPzVGKGiSGDCKiyy1goIbDHYJYmksmYpK+fo4PvUneaPmDSpBuu/lWqZZNZYLEkcJHyQKBgD6lrw6VBP7DblwI1sonVHWfihnYakNoO5zer9ob1D4Z2HQR+Vp28/BtQoEoRQlL4ep2F1J6I+z1uA3/mvaCzAE7B3UG4dWJK0OzGRzaeaJXiDuOofVuX0+0eW14IltPDFbyRIUf4jl8sODSEneLYbWfVqzQlI7n9Nrgp4QLcHZd");
      }
      else{
        setPubKeyFromStorage("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqGb7WwPn0K9sObxqSNaogm43i8o4eNFfjcyvViJVcVZOKxpKygYQmH95txprDeJf9glMhv4EHNT6cEthOpYHByMYeYD3BhW69fGOIyUMJxdo2MA7rPU3QvUMmVX0UOOx3E6E8NZnIb+Ootq8cUwknN0t4o4FEcxnciypAcno7BsT89B4KrArdz6JHRfwEhpcZn74POMmPzvbbKJhY4DoaUBDdtw5pGqajAPk/aXokeFYb2kpdHT42+XGzK6GbWB6eft9JkhngpWdGTTDn4/OpuoOk/QQ6oWJooHPpOnJ5Tdai4KuJzTQ8M4GsaycSQzQ8K2h+IcCEwIZLSWncyjWaQIDAQAB");
        setPrivateKeyFromStorage("MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCoZvtbA+fQr2w5vGpI1qiCbjeLyjh40V+NzK9WIlVxVk4rGkrKBhCYf3m3GmsN4l/2CUyG/gQc1PpwS2E6lgcHIxh5gPcGFbr18Y4jJQwnF2jYwDus9TdC9QyZVfRQ47HcToTw1mchv46i2rxxTCSc3S3ijgURzGdyLKkByejsGxPz0HgqsCt3PokdF/ASGlxmfvg84yY/O9tsomFjgOhpQEN23DmkapqMA+T9peiR4VhvaSl0dPjb5cbMroZtYHp5+30mSGeClZ0ZNMOfj86m6g6T9BDqhYmigc+k6cnlN1qLgq4nNNDwzgaxrJxJDNDwraH4hwITAhktJadzKNZpAgMBAAECggEBAIs7gexxYTOoJlniDxoj6HTWfbRlQKWbrl5F8l3Ly0sGqWB3v4gi1YvQMakS/ZogJWj9rTkbQfk4mctId54BttPOz4h9+T8drlN0ISmrks2rTDORVIWexM7mXkFU0MgkScS1YrLhAankgCDjqtQduVO8hxh+hXB+yLSceiuRbbPvH31QbzQ10O0dep7tC53vqqKGRpdrJ58tk1nYUB1jd29y3zxWfwl+ZoBH0K+bQaJ9RMkQhmfJ27nXOs301jT1Nos9/8OBu+84XQhhbH+O4sSNLF+cNwlBdJG4huq4a4kg6NbPr99VB9Dq5tVsTKRgFm6QaCvcONxd/WJPCESaG4ECgYEA9FWC+cvDiB/42I499IDqt3mx9DW/ZSFHM0dtuwTt0yAQskN1Yfmm0INUt3SRuztmg7WAychx1iiMgF2BolJcxA7RRE1+qcnJvKlMjRxHra4L/sGJtPwmZvTAbTUzNwqzB1+PYtYgJQ/9NtUoUX4mKH9LLg4EOYB6gkoeSgvsWpkCgYEAsHFbvsNwbcnU0Qv/QIu0TC7LOX4NnWqtQvZYKh/fSoIl9+gqGg+vF0gqqLPej8x53HMDqRhBWcy9G02NabUbzPsemrat3ALd1pjbfE3Uv7hHP+jTcvTWU83HKhN0iFkqempHaC3OxCTMcpjetdt1Bh5I/4Z/6FUxA1tB3I/JDFECgYA88dNwsWW9X5Q3mAtWII3rY/yCWKG7/PgAj3GMc6dKwTXI8VCnNploa0nHVNlA5YklkzFjo47Zh1W8cxZxwa+H69ZA/j945G9gkq4YiJRMexxc2DOcJEUD60rQMrPqp82OKkTet2BfPkS/151t7lRgR5geDbr6CNUGCKzTdXPoCQKBgCdxD6szERzZs0MPxX1uPV2SUEeH0A9SW2zOmKLCAS4srcQfF9o/i0pPDYosuyG1+b+3ziesjl8+jz9dNLFelNpbgFnhYDgARArGnLnKxDYfQX4d07as2IRfSZg0RSZ9mCtJOrElHEVoXHN5jL9mUWCOwI6uSEVtVcmEStK9KZohAoGAHSJhc1P+qp7IL63pKxO8anrx3yAsazWsKyfxXapx0rW7PEsTMslmeJArAg6gATLJ1TPN6ReXFgKehnO8pPzuY7Jp07r7qYxJYr1wESfq+gxckf0vntjFXM+Lxy4m7Pdm+bM/SCSm0kHDU9lkssfEHGYQtfx87JOnktukpp/J1I8=");
      }
    }
    else {
      final pair = generateRSAkeyPair(exampleSecureRandom());
      final public = pair.publicKey;
      final private = pair.privateKey;

      final pemPublicKey = encodePublicKeyToPem(public);
      final pemPrivateKey = encodePrivateKeyToPem(private);
      final pubKey = parsePublicKeyFromPem(pemPublicKey);
      //final privKey = parsePrivateKeyFromPem(pemPrivateKey);

      setPubKeyFromStorage(pemPublicKey);
      setPrivateKeyFromStorage(pemPrivateKey);
    }
  }
}

//region decrypt / encrypt
Uint8List encrypt(String message, String pubKey){
  List<int> list = message.codeUnits;
  Uint8List data = Uint8List.fromList(list);

  final pubKeyAlice = parsePublicKeyFromPem(pubKey);
  return  rsaEncrypt(pubKeyAlice, data);
}

//region decrypt
decrypt(Uint8List encryptData, String privateKey){
  final privKeyBites = parsePrivateKeyFromPem(privateKey);
  final decryptData = rsaDecrypt(privKeyBites, encryptData);
  return Utf8Decoder().convert(decryptData);
}
decryptFromString(String encryptData, String privateKey){
  return decryptFromListInt(jsonDecode(encryptData).cast<int>(), privateKey);
}
decryptFromListInt(List<int> list, String privateKey){
  Uint8List bytes = Uint8List.fromList(list);
  return decrypt(bytes, privateKey);
}
//endregion
//endregion

//region signature
addSignature(String encryptData, String signature){
  return "$encryptData.$signature";
}
splitSignedAndCryptedMessage(String message){
  List<String> list = message.split(".");
  return {"encryptedMsg":list[0], "signature":list[1]};
}
// fonction qui permet de créer la signature
Uint8List rsaSign(RSAPrivateKey privateKey, Uint8List dataToSign) {
  final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // true=sign
  final sig = signer.generateSignature(dataToSign);
  return sig.bytes;
}
Uint8List rsaSignFromKeyString(String privateKey, Uint8List dataToSign) {
  return rsaSign( parsePrivateKeyFromPem(privateKey), dataToSign);
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
bool rsaVerifyFromKeyString(String publicKey, Uint8List signedData, Uint8List signature) {
  return rsaVerify( parsePublicKeyFromPem(publicKey), signedData, signature);
}
bool rsaVerifyFromKeyStringAndListInt(String publicKey, List<int> listSignedData, List<int> listSignature) {
  return rsaVerify( parsePublicKeyFromPem(publicKey), Uint8List.fromList(listSignedData), Uint8List.fromList(listSignature));
}
bool rsaVerifyFromKeyStringAndStringBytes(String publicKey, String listSignedData, String listSignature) {
  return rsaVerifyFromKeyStringAndListInt(publicKey, jsonDecode(listSignedData).cast<int>(), jsonDecode(listSignature).cast<int>());
}
//endregion
