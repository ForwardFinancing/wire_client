$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/reporters'
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
Minitest::Reporters.use!

require 'mocha/mini_test'
require 'pry'

require 'codeclimate-test-reporter'
SimpleCov.minimum_coverage 40
SimpleCov.start do
  add_filter '/test'
end

# Freeze time so we don't have to worry about Time.now relativity
require 'timecop'
Timecop.freeze(DateTime.parse('2016-08-11T10:13:05-04:00+00:00'))

# Everything happens synchronously
require 'sucker_punch/testing/inline'

require 'wire_client'

# Configure test settings
WireClient::HSBC::WireBatch.initiator_name = 'Forward Financing LLC'
WireClient::HSBC::WireBatch.initiator_wire_routing_number = '021001088'
WireClient::HSBC::WireBatch.initiator_account_number = '927407619'
WireClient::HSBC::WireBatch.initiator_identifier = 'FORWARDFINANCINGID'
WireClient::HSBC::WireBatch.initiator_country_subdivision = 'MA'

WireClient::HSBC.host = 'localhost:3000'
WireClient::HSBC.username = 'HSBCTester'
WireClient::HSBC.password = 'HSBCAviatoRulez7'
WireClient::HSBC.private_ssh_key = "-----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgQCSNnQuvjgxxXMLSCwOUHiRUuJax2n5RETzQEdlt+qz0v2vmOqY
KOxPWRTu3qApIOgpoUUJ2QELNWD6b9wIB8Py6Op7Jxp/3kvHpfpsOFxZ5if7MALG
+OFMmjNzjjAzcs833We1Qlmsq/0mOZQPj5CrnxgQIRF1IyD07hyW7fwmZQIDAQAB
AoGAfgiKZbB6aAy3ekYgE8ax5zL3AyFZ7BA5DyWdZcT/fzqkirTZo4fDCzLSpIUq
sck31oq5JB/2kl7U1YuOsy1eba6QvWjm3STsIVMZZSRAlveCZXP1St7VO6EpYp1u
joUS/R6ZvrQMKjfoJSgg8aLencKKI4HoPPfMU/MOxHm4sgECQQD/F7sgIapa4+Fu
7Rmsg4szoCc5EWRM6HaXZYG/mq8yzKXcIv07rK0m3oRmPl24N8AaFHiWHoXIgDC9
ALXw1g1hAkEAkruVqIOHR8zfIY9TBznS4leNiFvrggJAJg5LZK8X36SXwxBF6XFj
V5NFZcAyoWuD0BgjWhlsLDND/HUUz2kThQJAAhgVxyu/lENupFR583qY9/GGoOdN
pXv7DT8eE46XhZk8e1QmNAk02q7U82nrpwl+IDiuzLyvaHf07nhFBhcbwQJATlAz
5gadEyMzC9RU+gxQk2ErNtXocjEFT8pdTtVspn5QSVnMFnXgEYOWjGHyI9kgNtZL
N/FNnKGX7YwHmVN5iQJAP/neHXHkGnAOKubNcKceiN6CsgpMJwljuRAYUCXyqR5F
RyA0Apd7gmXpC2guaLTvDzpo9d8iR5MKDw6cYUyQsg==
-----END RSA PRIVATE KEY-----"
WireClient::HSBC.outgoing_path = '/root/wire_sandbox'
WireClient::HSBC.outgoing_path = '/root/wire_sandbox/Inbox'
WireClient::HSBC.file_naming_strategy = lambda do |batch_number|
  batch_number ||= 1
  "WIRE#{Date.today.strftime('%m%d%y')}#{batch_number.to_s.rjust(2, '0')}.xml"
end

WireClient::HSHNordbankHamburg::WireBatch.initiator_name = 'Business from Germany'
WireClient::HSHNordbankHamburg::WireBatch.initiator_bic = 'HSHNDEHHXXX'
WireClient::HSHNordbankHamburg::WireBatch.initiator_iban = 'DE87200500001234567890'
WireClient::HSHNordbankHamburg::WireBatch.initiator_identifier = 'DE98ZZZ09999999999'

WireClient::HSHNordbankHamburg.host = 'localhost:3000'
WireClient::HSHNordbankHamburg.username = 'HSHNordbankHamburgTester'
WireClient::HSHNordbankHamburg.password = 'HSHNordbankHamburgAviatoRulez7'
WireClient::HSHNordbankHamburg.private_ssh_key = "-----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgH6s2p8X692q+d4kD6HhhagudbBoxiRFOGQT1x36pu7YpozP7fj2
u1hDPZ7QOPvlB4KHk8P2eUNxt6sSmWXxc8FOk4TmLMAzkzdk/pi6zkIM3nriOsbm
lGa36y5tIYbW8zmliw2sGB8/YeB635ioBPUVu689NsIjUjpsx0WOW8EtAgMBAAEC
gYA20oIvNkAbCCLpc7vcOGkK10iR11ZhXh/AmCGSVOcoGVVDPb3k8Is18Kvbbowq
3/z3DcvylFn4yV9Ox1biGrQYhCCmxcPWCV7aJ53gCgUdlHvdiBoXjEo5Gz70J6NW
pv7uxZosnt6nd9ACYg/OO4g052pluTKyAv4mLUx4XoejVQJBAO01GnytrHV0qLTH
kQEp0IUL3Di50G1zJd4jjml+97uFBMqCCgCNvev1p285mA6p3TkBrURXcPjaI4pR
BhUxEUsCQQCItgDcMPpw/EpgY9+pD3wMna7dIo49QSf2U/bbA6W7X0eiMOElVTJl
c7sGqhs/0xQu3jonFLP5gKBVzB0hReRnAkAr8oC7xLmE8V4oUCkPXB3j6HSeld6F
yKWlaFUEOp/PQC/JDRqpS5l6VAL3WmZPoSz5WNQvKzwk/tVC1QwZdQPNAkAJdtge
ZkGgOscHX0KnmIvU78GgS3kfYnhaxDtNtDXv/8ucvdeIVxqTDW0ALByQ0ZMPH5FV
DUjcV/xBlEzb9dO3AkEA2JLfE998lka8emp/jwmLpnFc2EjWwGIEDHxVNeSNdd0U
guSskdloMQfuKT+RQ0VBi6V7vZAmL/OQ/jtxG9HNrA==
-----END RSA PRIVATE KEY-----"
WireClient::HSHNordbankHamburg.outgoing_path = '/root/wire_sandbox'
WireClient::HSHNordbankHamburg.outgoing_path = '/root/wire_sandbox/Inbox'
WireClient::HSHNordbankHamburg.file_naming_strategy = lambda do |batch_number|
  batch_number ||= 1
  "WIRE#{Date.today.strftime('%m%d%y')}#{batch_number.to_s.rjust(2, '0')}.xml"
end
