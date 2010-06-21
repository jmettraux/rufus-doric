# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rufus-doric}
  s.version = "0.1.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mettraux"]
  s.date = %q{2010-06-21}
  s.description = %q{
something at the intersection of Rails3, CouchDB and rufus-jig
  }
  s.email = %q{jmettraux@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.txt",
     "LICENSE.txt",
     "README.rdoc",
     "Rakefile",
     "TODO.txt",
     "lib/rufus-doric.rb",
     "lib/rufus/doric.rb",
     "lib/rufus/doric/couch.rb",
     "lib/rufus/doric/fixtures.rb",
     "lib/rufus/doric/model.rb",
     "lib/rufus/doric/models.rb",
     "lib/rufus/doric/one_doc_model.rb",
     "lib/rufus/doric/value.rb",
     "lib/rufus/doric/version.rb",
     "rufus-doric.gemspec",
     "test/al_vetro.png",
     "test/base.rb",
     "test/fixtures/test/doric/69247b__picture.jpg",
     "test/fixtures/test/doric/69249__picture.jpg",
     "test/fixtures/test/doric/product0.json",
     "test/fixtures/test/doric/product1.json",
     "test/fixtures/test/doric/tuples.json",
     "test/fixtures/test/doric/users.json",
     "test/fixtures/test/doric/users__jami.png",
     "test/fixtures/test/doric/users__john.jpg",
     "test/fixtures/test/doric_ENV_workitems/workitem0.json",
     "test/test.rb",
     "test/ut_0_fixtures.rb",
     "test/ut_10_value.rb",
     "test/ut_11_model_view_range.rb",
     "test/ut_12_model_default.rb",
     "test/ut_13_one_doc_model_default.rb",
     "test/ut_14_model_default_id.rb",
     "test/ut_15_model_view_by_and.rb",
     "test/ut_16_model_custom_view.rb",
     "test/ut_17_model_and_attachments.rb",
     "test/ut_18_model_map_reduce.rb",
     "test/ut_19_neutralize_id.rb",
     "test/ut_1_model.rb",
     "test/ut_2_model_view.rb",
     "test/ut_3_model_lint.rb",
     "test/ut_4_one_doc_model.rb",
     "test/ut_5_one_doc_model_lint.rb",
     "test/ut_6_model_associations.rb",
     "test/ut_7_looser_associations.rb",
     "test/ut_8_belongings.rb",
     "test/ut_9_any.rb"
  ]
  s.homepage = %q{http://github.com/jmettraux/rufus-doric/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rufus}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{something at the intersection of Rails3, CouchDB and rufus-jig}
  s.test_files = [
    "test/test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["~> 3.0.0.beta4"])
      s.add_runtime_dependency(%q<rufus-jig>, [">= 0.1.19"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["~> 3.0.0.beta4"])
      s.add_dependency(%q<rufus-jig>, [">= 0.1.19"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 3.0.0.beta4"])
    s.add_dependency(%q<rufus-jig>, [">= 0.1.19"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

