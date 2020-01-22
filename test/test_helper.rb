$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_support/all'
Time.zone = 'Eastern Time (US & Canada)'

require 'codeclimate-test-reporter'
SimpleCov.minimum_coverage 100
SimpleCov.start do
  add_filter '/test'
end

require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/reporters'
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
Minitest::Reporters.use!

require 'mocha/minitest'
require 'pry'

# Freeze time so we don't have to worry about Time.now relativity
require 'timecop'
Timecop.freeze(DateTime.parse('2016-08-11T10:13:05-04:00+00:00'))

# Everything happens synchronously
require 'sucker_punch/testing/inline'

require 'wire_client'

module MiniTest::Assertions
  def assert_valid_values(klass, values:, attributes:)
    attributes.each do |attribute|
      values.each do |value|
        subject = klass.new attribute => value
        subject.validate
        assert_equal subject.errors[attribute].size, 0
      end
    end
  end

  def refute_invalid_values(klass, values:, attributes:)
    attributes.each do |attribute|
      values.each do |value|
        subject = klass.new attribute => value
        subject.validate
        assert subject.errors.size > 0
      end
    end
  end
end

# Configure test settings
WireClient::FakeBank::WireBatch.initiator_name = 'Forward Financing LLC'
WireClient::FakeBank::WireBatch.initiator_wire_routing_number = '123456789'
WireClient::FakeBank::WireBatch.initiator_account_number = '987654321'
WireClient::FakeBank::WireBatch.initiator_identifier = 'FORWARDFINANCINGID'
WireClient::FakeBank::WireBatch.initiator_country = 'US'
WireClient::FakeBank::WireBatch.initiator_country_subdivision = 'MA'
WireClient::FakeBank::WireBatch.initiator_postal_code = '02116'
WireClient::FakeBank::WireBatch.initiator_address_line = '99 Unknown Sidewalk'
WireClient::FakeBank::WireBatch.initiator_city = 'Boston'

WireClient::FakeBank.host = 'localhost:3000'
WireClient::FakeBank.username = 'FakeBankTest'
WireClient::FakeBank.password = 'FakeBankTestPassword'
WireClient::FakeBank.private_ssh_key = "-----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgQCSNnQuvjgxxXMLSCwOUHiRUuJax2n5RETzQEdlt+qz0v2vmOqY
KOxPWRTu3qApIOgpoUUJ2QELNWD6b9wIB8Py6Op7Jxp/3kvHpfpsOFxZ5if7MALG
+OFMmjNzjjAzcs833We1Qlmsq/0mOZQPj5CrnxgQIRF1IyD07hyW7fwmZQIDAQAB
AoGAfgiKZbB6aAy3ekYgE8ax5zL3AyFZ7BA5DyWdZcT/fzqkirTZo4fDCzLSpIUq
sck31oq5JB/2kl7U1YuOsy1eba6QvWjm3STsIVMZZSRAlveCZXP1St7VO6EpYp1u
joUS/R6ZvrQMKjfoJSgg8aLencKKI4aoPPfMU/MOxHm4sgECQQD/F7sgIapa4+Fu
7Rmsg4szoCc5EWRM6HaXZYG/mq8yzKXcIv07rK0m3oRmPl24N8AaFHiWHoXIgDC9
ALXw1g1hAkEAkruVqIOHR8zfIY9TBznS4leNiFvrggJAJg5LZK8X36SXwxBF6XFj
V5NFZcAyoWuD0BgjWhlsLDND/HUUz2kThQJAAhgVxyu/lENupFR583qY9/GGoOdN
pXv7DT8eE46dhZk8e1QmNAk02q7U82crpwl+IDiuzLyvaHf07nhFBhcbwQJATlAz
5gadEyMzC9RU+gxQk2ErNtXocjEFT8pdTtVspn5QSVnMFnXgEYOWjGHyI9kgNtZL
N/FNnKGX7YwHmVN5iQJAP/neHXHkGnbOKubNcKceiN6CsgpMJwljuRAYUCXyqR5F
RyA0Apd7gmXpC2guaLTvDzpo9d8iR5MKDw6cYUyQsg==
-----END RSA PRIVATE KEY-----"
WireClient::FakeBank.outgoing_path = '/root/wire_sandbox'
WireClient::FakeBank.outgoing_path = '/root/wire_sandbox/Inbox'
WireClient::FakeBank.file_naming_strategy = lambda do |batch_number|
  batch_number ||= 1
  "WIRE#{Date.today.strftime('%m%d%y')}#{batch_number.to_s.rjust(2, '0')}.xml"
end

WireClient::OtherFakeBank::WireBatch.initiator_name = 'Fake Business'
WireClient::OtherFakeBank::WireBatch.initiator_bic = 'FAKEBANKBIC'
WireClient::OtherFakeBank::WireBatch.initiator_iban = 'US12345678912345678912'
WireClient::OtherFakeBank::WireBatch.initiator_identifier = 'US99ZZZ99999999999'
WireClient::OtherFakeBank::WireBatch.initiator_country = 'US'

WireClient::OtherFakeBank.host = 'localhost:3000'
WireClient::OtherFakeBank.username = 'OtherFakeBank'
WireClient::OtherFakeBank.password = 'OtherFakeBankPassword'
WireClient::OtherFakeBank.private_ssh_key = "-----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgH6s2p8X692q+d4kD6HhhagudbBoxiRFOGQT1x36pu7YpozP7fj2
u1hDPZ7QOPvlB4KHk8P2eUNxt6sSmWXxc8FOk4TmLMAzkzdk/pi6zkIM3nriOsbm
lGa36y5tIYbW8zmliw2sGB8/YeB635ioBPUVu689NsIjUjpsx0WOW8EtAgMBAAEC
gYA20oIvNkAbCCLpc7vcOGkK10iR11ZhXh/AmCGSVOcoGVVDPb3k8Is18Kvbbowq
3/z3DcvylFn4yV9Ox1biGrQYhCCmxcPWCV7aJ53gCgUdlHvdiBoXjEo5Gz70J6NW
pv7uxZosnt6nd9ACYg/OO4g052pluTKyAv4mLUx4XoejVQJBAO01GnytrHV0qLTH
kQEp0IUL3Di50G1zJd4jjml+97uFBMqCCgCNvev1p285mA6p3123rURXcPjaI4pR
BhUxEUsCQQCItgDcMPpw/EpgY9+pD3wMna7dIo49QSf2U/bbA6W7X0eiMOElVTJl
c7sGqhs/0xQu3jonFLP5gKBVzB0hReRnAkAr8oC7xLmE8V4oUCkPXB3j6HSeld6F
yKWlaFUEOp/PQC/JDRqpS5l6abc3WmZPoSz5WNQvKzwk/tVC1QwZdQPNAkAJdtge
ZkGgOscHX0KnmIvU78GgS3kfYnhaxDtNtDXv/8ucvdeIVxqTDW0ALByQ0ZMPH5FV
DUjcV/xBlEzb9dO3AkEA2JLfE998lka8emp/jwmLpnFc2EjWwGIEDHxVNeSNdd0U
guSskdloMQfuKT+RQ0VBi6V7vZawL/OQ/jtxG9HNrA==
-----END RSA PRIVATE KEY-----"
WireClient::OtherFakeBank.outgoing_path = '/root/wire_sandbox'
WireClient::OtherFakeBank.outgoing_path = '/root/wire_sandbox/Inbox'
WireClient::OtherFakeBank.file_naming_strategy = lambda do |batch_number|
  batch_number ||= 1
  "WIRE#{Date.today.strftime('%m%d%y')}#{batch_number.to_s.rjust(2, '0')}.xml"
end
