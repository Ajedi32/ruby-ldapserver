#!/usr/local/bin/ruby -w

$:.unshift('../lib')
require 'test/unit'
require 'ldap/server/filter'

class FilterTest < Test::Unit::TestCase

  AV1 = {
    "foo" => ["abc","def"],
    "bar" => ["wibblespong"],
  }

  def test_bad
    assert_raises(LDAP::Server::OperationsError) {
      LDAP::Server::Filter.run([:wibbly], AV1)
    }
  end

  def test_const
    assert_equal(true, LDAP::Server::Filter.run([:true], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:false], AV1))
    assert_equal(nil, LDAP::Server::Filter.run([:undef], AV1))
  end

  def test_present
    assert_equal(true, LDAP::Server::Filter.run([:present,"foo"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:present,"zog"], AV1))
  end

  def test_eq
    assert_equal(true, LDAP::Server::Filter.run([:eq,"foo","abc"], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:eq,"foo","def"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:eq,"foo","ghi"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:eq,"xyz","abc"], AV1))
  end

  def test_eq_case
    c = LDAP::Server::MatchingRule::CaseIgnoreMatch
    assert_equal(true, LDAP::Server::Filter.run([c,:eq,"foo","ABC"], AV1))
    assert_equal(true, LDAP::Server::Filter.run([c,:eq,"foo","DeF"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([c,:eq,"foo","ghi"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([c,:eq,"xyz","abc"], AV1))
  end

  def test_not
    assert_equal(false, LDAP::Server::Filter.run([:not,[:eq,"foo","abc"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:not,[:eq,"foo","def"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:not,[:eq,"foo","ghi"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:not,[:eq,"xyz","abc"]], AV1))
  end

  def test_ge
    assert_equal(true, LDAP::Server::Filter.run([:ge,"foo","ccc"], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:ge,"foo","def"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:ge,"foo","deg"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:ge,"xyz","abc"], AV1))
  end

  def test_le
    assert_equal(true, LDAP::Server::Filter.run([:le,"foo","ccc"], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:le,"foo","abc"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:le,"foo","abb"], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:le,"xyz","abc"], AV1))
  end

  def test_substrings
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:initial,"a"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:initial,"def"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"foo",[:initial,"bc"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"foo",[:initial,"az"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:initial,""]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"zzz",[:initial,""]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:any,"a"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:any,"e"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"foo",[:any,"ba"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"foo",[:any,"az"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:final,"c"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"foo",[:final,"ef"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"foo",[:final,"ab"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"foo",[:final,"e"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"bar",[:initial,"wib"],[:final,"ong"]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:substrings,"bar",[:initial,""],[:final,""]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"bar",[:initial,"wib"],[:final,"ble"]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:substrings,"bar",[:initial,"sp"],[:final,"ong"]], AV1))
  end

  def test_and
    assert_equal(true, LDAP::Server::Filter.run([:and,[:true],[:true]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:and,[:false],[:true]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:and,[:true],[:false]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:and,[:false],[:false]], AV1))
  end

  def test_or
    assert_equal(true, LDAP::Server::Filter.run([:or,[:true],[:true]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:or,[:false],[:true]], AV1))
    assert_equal(true, LDAP::Server::Filter.run([:or,[:true],[:false]], AV1))
    assert_equal(false, LDAP::Server::Filter.run([:or,[:false],[:false]], AV1))
  end

end
