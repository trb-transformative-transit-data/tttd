# TRB Standing Committee on Transit Data - TRB AP090

This website hosts the TRB Standing Committee on Transit Data.

## Why GitHub?

It's a clever way of managing code, and a website is just a bunch of code

## Testing locally

While working on the website locally on your computer, it can be helpful to preview what your changes will look like before pushing them up to GitHub.

### Ruby Setup

This project uses Ruby 3.2.2. The recommended way to manage Ruby versions is with [asdf](https://asdf-vm.com/):

```bash
# Install Ruby if you haven't already
asdf plugin add ruby
asdf install ruby 3.2.2

# In the project directory, set Ruby version
asdf local ruby 3.2.2

# Verify Ruby version
ruby --version  # Should show 3.2.2
```

### Running the site

Once Ruby is set up:

```bash
bundle install
bundle exec jekyll serve
```

GitHub offers a more comprehensive guide if you have trouble with the above: [Testing your Github Pages site locally with Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll)
