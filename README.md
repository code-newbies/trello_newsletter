# TrelloNewsletter

The Trello Newsletter gem is inspired by the Changelog's *[Trello as a CMS](https://thechangelog.com/trello-as-a-cms/)* blog post.
The gem converts cards in a Trello board into a HTML newsletter which is sent to Mailchimp ready to be sent out.

It's currently specific to Code Newbie but there will be steps to make it more accessible to everyone.

## Usage

#### <a name="setup"></a>Setup 
Before we can begin, clone the gem into your directory, with ssh: 

`$ git clone git@github.com:code-newbies/trello_newsletter.git`

Or clone the gem, without ssh (you'll need to enter in your GitHub login details):

`$ git clone https://github.com/code-newbies/trello_newsletter.git`

Next is setting up your environment variables. Your environment variables will store your secret API key's. 
We need two sets of API key's to get this working; Trello and Mailchimp.

#### Trello key
We use the [ruby-trello](https://github.com/jeremytregunna/ruby-trello) gem and these instructions are appropriated from
that project.

1. Login to your Trello account.
2. Get your api key from [trello.com/app-key](https://trello.com/app-key). Set it as environment variable 'TRELLO_DEVELOPER_PUBLIC_KEY'.
To do this enter this command in your terminal:

`$ export TRELLO_DEVELOPER_PUBLIC_KEY=YOURAPIKEY`

To make sure that this is loaded every time you start a new terminal session. You can place this command in `~/.profile` or `~/.bash_profile`.

3. Get your member token by visiting this url: `https://trello.com/1/authorize?key=YOURAPIKEY&response_type=token&expiration=never`
  - key: Your api key, the key that you got from step one.
  - response_type: 'token'
  - expiration: 'never' if you want your token to never expire (which is what we want). If you leave this blank the token
      generated will expire in 30 days.

Set the member token to an environment variable called 'TRELLO_MEMBER_TOKEN' using the process in step 1.

#### Mailchimp key

1. Login to Mailchimp.
2. Navigate to 'account settings' in Mailchimp.
3. Under 'Extras' menu there is an 'Api Keys' option.
4. On that page under the 'Your API keys' heading you have an option to create a new key. Set the key value generated to an environment
variable named 'MAILCHIMP_KEY'. Like with the Trello key, enter this command in your terminal:

`$ export MAILCHIMP_KEY=YOURAPIKEY`

Again to make sure that this key is loaded every time you start a new terminal session. You can place this command in `~/.profile` or `~/.bash_profile`.

#### Generating the newsletter

Once we have both the Mailchimp and Trello Api keys we can go ahead and generate the newsletter.

1. Navigate to the `Trello_newsletter` project, which you would have cloned in the [earlier step](#setup).
2. `bundle install` to install any dependencies.
3. Run `rake generate`.

This rake task will do two things:

1. Generate your email HTML file using information from the Trello board. This zip file will be placed in your project root folder.
2. Zip the file (and a header_image.png if included) and then send it to Mailchimp.

To see the newsletter in Mailchimp:

1. Log in to Mailchimp.
2. Click on Campaigns.
3. You should see your generated template saved as a draft.

## Contributing

1. Fork it by pressing that GitHub fork button at the top of the page. 
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
