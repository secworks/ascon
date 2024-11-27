# Ascon

## Status
Implementation started but not yet completed. We also need a model and test vectors from NIST before the core can be verified.

The core does not work. **DO. NOT. USE.**

## Introduction
Verilog implementation of the [Ascon](https://ascon.iaik.tugraz.at/)
lightweight authenticated encryption, hashing and extendable output
function (XOF) algorithm. 

This implementation follows the proposed standard NIST specifies in
[NIST SP 800-232 ipd, Ascon-Based Lightweight Cryptography Standards
for Constrained
Devices](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-232.ipd.pdf)
(pdf).

The implementation is fairly slow, with one round per cycle. The core
supports 6, 12 and 16 rounds.
