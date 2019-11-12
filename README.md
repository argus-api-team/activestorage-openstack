[![Gem Version](https://badge.fury.io/rb/activestorage_openstack.svg)](https://badge.fury.io/rb/activestorage_openstack) [![Maintainability](https://api.codeclimate.com/v1/badges/75b77a2b9d9b42496264/maintainability)](https://codeclimate.com/github/argus-api-team/activestorage-openstack/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/75b77a2b9d9b42496264/test_coverage)](https://codeclimate.com/github/argus-api-team/activestorage-openstack/test_coverage) [![Build Status](https://travis-ci.org/argus-api-team/activestorage-openstack.svg?branch=master)](https://travis-ci.org/argus-api-team/activestorage-openstack) [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=argus-api-team/activestorage-openstack)](https://dependabot.com)

# Active Storage OpenStack service

Active Storage facilitates uploading files to a cloud storage service like Amazon S3, Google Cloud Storage, or Microsoft Azure Storage and attaching those files to Active Record objects.

This gem adds support for the OpenStack [Object Storage API](https://developer.openstack.org/api-ref/object-store/).

The goal is to interact with the OpenStack API without any third party tools (Swift, Fog...).

We use the standard [Net::HTTP](https://ruby-doc.org/stdlib/libdoc/net/http/rdoc/Net/HTTP.html) ruby library.

We stay up-to-date with the [Ruby](https://www.ruby-lang.org/en/downloads/releases/) and [Rails](https://weblog.rubyonrails.org/releases/) versions.

## Getting Started

In your `Gemfile` add this line:

```ruby
gem 'activestorage_openstack'
```

### Prerequisites

In your Rails `config/storage.yml` file add your OpenStack configuration:

```yml
openstack:
  service: Openstack
  container: __container__
  authentication_url: __authentication_url__
  region: __region__
  credentials:
    username: __username__
    api_key: __api_key__
    temporary_url_key: __temporary_url_key__
```

Then add to your `config/environments/*.rb` files:

```ruby
Rails.application.configure do
  ...
  config.active_storage.service = :openstack
  ...
end
```

### Installing

If you want to add features to the gem, clone the repository and use Docker:

```bash
$ git clone https://github.com/argus-api-team/activestorage-openstack.git
$ cd activestorage-openstack
$ docker image build -t activestorage_openstack .
```

## Running the tests

We use the [Guard](https://github.com/guard/guard) gem to run tests:

```bash
$ docker container run -e RAILS_ENV=test -v $(pwd):/app -it activestorage_openstack guard -g red_green_refactor -c
```

The `red_green_refactor` Guard group means:
* It runs Rspec tests with [Spring](https://github.com/rails/spring).
* It watches `Gemfile` for changes.
* It uses [Rubocop](https://github.com/rubocop-hq/rubocop) and [Reek](https://github.com/troessner/reek) for linting/coding style.

See [Guardfile](Guardfile) for details.

## Built with

* [Net::HTTP](https://ruby-doc.org/stdlib/libdoc/net/http/rdoc/Net/HTTP.html) - From the standard Ruby Library.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

* **Mickael PALMA** - *Initial work* - [mickael-palma-argus](https://github.com/mickael-palma-argus)

See also the list of [contributors](https://github.com/argus-api-team/activestorage-openstack/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [MIT-LICENSE](MIT-LICENSE) file for details

## Acknowledgments

* Inspiration from [@chaadow's](https://github.com/chaadow) [activestorage-openstack plugin](https://github.com/chaadow/activestorage-openstack)
