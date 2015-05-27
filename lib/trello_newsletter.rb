require_relative "trello_newsletter/version"
require_relative "meta.rb"
require_relative "post.rb"
require "pry"
require "trello"
require "gibbon"
require "zip"
require "base64"

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class TrelloNewsletter
  REJECTED_LISTS = [ "Meta", "Mailchimp doc info", "Callouts", "Sponsors" ]

  def board_name
    "CodeNewbie Newsletter"
  end

  def board
    Trello::Board.all.find { |b| b.name == board_name }
  end

  def generate
    lists = board.lists

    meta_list = lists.select { |n| n.attributes[:name] == "Meta" }.first
    meta = Meta.new(meta_list)

    @title = meta.title
    #headlines_list = lists.select { |n| n.attributes[:name] == "Headlines" }.first
    content_lists = lists.reject { |n| REJECTED_LISTS.include?(n.attributes[:name]) }
    callouts = lists.find { |n| n.attributes[:name] == "Callouts" }
    sponsors = lists.find { |n| n.attributes[:name] == "Sponsors" }

    puts "starting html output"
    html_output(meta, content_lists, callouts, sponsors)
    puts "zippity zip zip"
    zip_output
    puts "Finished generating issue"
  end

  def newsletter_title
    @title
  end

  def zip_output # It would be nice to pass in a filename rather than hardcoding it
    # This tells zip to overwrite the zip
    Zip.continue_on_exists_proc = true # Should put this in a configuration file.
    Zip::File.open("newsletter_html.zip", Zip::File::CREATE) do |zip|
      zip.add("index.html", "./index.html")
      if File.exists?("header_image.png")
        zip.add("header_image.png", "./header_image.png")
      end
    end
  end


  def html_output(meta, content_lists, callouts, sponsors)
    template = File.open("index.html", "w")
    template.puts <<-DOC
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

            <!-- Facebook sharing information tags -->
            <meta property="og:title" content="*|MC:SUBJECT|*" />

            <title>*|MC:SUBJECT|*</title>
        <style type="text/css">
          /* Client-specific Styles */
          #outlook a{padding:0;} /* Force Outlook to provide a "view in browser" button. */
          body{width:100% !important;} .ReadMsgBody{width:100%;} .ExternalClass{width:100%;} /* Force Hotmail to display emails at full width */
          body{-webkit-text-size-adjust:none;} /* Prevent Webkit platforms from changing default text sizes. */

          /* Reset Styles */
          body{margin:0; padding:0;}
          img{border:0; height:auto; line-height:100%; outline:none; text-decoration:none;}
          table td{border-collapse:collapse;}
          #backgroundTable{height:100% !important; margin:0; padding:0; width:100% !important;}

          /* Template Styles */

          /* /\/\/\/\/\/\/\/\/\/\ STANDARD STYLING: COMMON PAGE ELEMENTS /\/\/\/\/\/\/\/\/\/\ */

          /**
          * @tab Page
          * @section background color
          * @tip Set the background color for your email. You may want to choose one that matches your company's branding.
          * @theme page
          */
          body, #backgroundTable{
            /*@editable*/ background-color:#F2F2F2;
          }

          #templateBody {
            width: 600px;
          }

          /**
          * @tab Page
          * @section email border
          * @tip Set the border for your email.
          */
          #templateContainer{
            width: 600px;
            /*@editable*/ /*border: 1px solid #DDDDDD*/;
            border: 0;
          }

          /**
          * @tab Page
          * @section heading 1
          * @tip Set the styling for all first-level headings in your emails. These should be the largest of your headings.
          * @style heading 1
          */
          h1, .h1{
            /*@editable*/ color:#7ed321;
            display:block;
            /*@editable*/ font-family:Helvetica;
            /*@editable*/ font-size:10px;
            /*@editable*/ text-transform:uppercase;
            /*@editable*/ font-weight:bold;
            /*@editable*/ line-height:150%;
            margin-top:0;
            margin-right:0;
            margin-bottom:0;
            margin-left:0;
            /*@editable*/ text-align:left;
          }

          /**
          * @tab Page
          * @section heading 2
          * @tip Set the styling for all second-level headings in your emails.
          * @style heading 2
          */
          h2, .h2{
            /*@editable*/ color:#606060;
            display:block;
            /*@editable*/ font-family:Arial;
            /*@editable*/ font-size:16px;
            /*@editable*/ line-height:100%;
            margin-top:0;
            margin-right:0;
            margin-bottom:10px;
            margin-left:0;
            /*@editable*/ text-align:left;
          }

          /**
          * @tab Page
          * @section heading 3
          * @tip Set the styling for all third-level headings in your emails.
          * @style heading 3
          */
          h3, .h3{
            /*@editable*/ color:#202020;
            display:block;
            /*@editable*/ font-family:Arial;
            /*@editable*/ font-size:26px;
            /*@editable*/ font-weight:bold;
            /*@editable*/ line-height:100%;
            margin-top:0;
            margin-right:0;
            margin-bottom:10px;
            margin-left:0;
            /*@editable*/ text-align:left;
          }

          /**
          * @tab Page
          * @section heading 4
          * @tip Set the styling for all fourth-level headings in your emails. These should be the smallest of your headings.
          * @style heading 4
          */
          h4, .h4{
            /*@editable*/ color:#202020;
            display:block;
            /*@editable*/ font-family:Arial;
            /*@editable*/ font-size:22px;
            /*@editable*/ font-weight:bold;
            /*@editable*/ line-height:100%;
            margin-top:0;
            margin-right:0;
            margin-bottom:10px;
            margin-left:0;
            /*@editable*/ text-align:left;
          }

          hr {
            border: 0;
            border-top: 2px solid #7ed321;
          }



          /* /\/\/\/\/\/\/\/\/\/\ STANDARD STYLING: PREHEADER /\/\/\/\/\/\/\/\/\/\ */

          /**
          * @tab Header
          * @section preheader style
          * @tip Set the background color for your email's preheader area.
          * @theme page
          */
          #templatePreheader{
            width: 600px;
            /*@editable*/ background-color:#FFFFFF;
          }

          /**
          * @tab Header
          * @section preheader text
          * @tip Set the styling for your email's preheader text. Choose a size and color that is easy to read.
          */
          .preheaderContent div{
            /*@editable*/ color:#505050;
            /*@editable*/ font-family:Arial;
            /*@editable*/ font-size:10px;
            /*@editable*/ line-height:100%;
            /*@editable*/ text-align:left;
          }

          /**
          * @tab Header
          * @section preheader link
          * @tip Set the styling for your email's preheader links. Choose a color that helps them stand out from your text.
          */
          .preheaderContent div a:link, .preheaderContent div a:visited, /* Yahoo! Mail Override */ .preheaderContent div a .yshortcuts /* Yahoo! Mail Override */{
            /*@editable*/ color:#7ed321;
            /*@editable*/ font-weight:normal;
            /*@editable*/ text-decoration:none;
          }
          
          .archive-text{
            text-align: right;
            line-height: 120%;
          }

          /* /\/\/\/\/\/\/\/\/\/\ STANDARD STYLING: HEADER /\/\/\/\/\/\/\/\/\/\ */

          /**
          * @tab Header
          * @section header style
          * @tip Set the background color and border for your email's header area.
          * @theme header
          */
          #templateHeader{
            width: 600px;
            /*@editable*/ background-color:#FFFFFF;
            /*@editable*/ border-bottom:0;
          }

          .title_text {
            font-size:30px; 
            text-align: center;
          }

          /**
          * @tab Header
          * @section header text
          * @tip Set the styling for your email's header text. Choose a size and color that is easy to read.
          */
          .headerContent{
            /*@editable*/ color:#202020;
            /*@editable*/ font-family:Arial;
            /*@editable*/ font-size:34px;
            /*@editable*/ font-weight:bold;
            /*@editable*/ line-height:100%;
            /*@editable*/ padding:0;
            /*@editable*/ text-align:center;
            /*@editable*/ vertical-align:middle;
          }

          /**
          * @tab Header
          * @section header link
          * @tip Set the styling for your email's header links. Choose a color that helps them stand out from your text.
          */
          .headerContent a:link, .headerContent a:visited, /* Yahoo! Mail Override */ .headerContent a .yshortcuts /* Yahoo! Mail Override */{
            /*@editable*/ color:#336699;
            /*@editable*/ font-weight:normal;
            /*@editable*/ text-decoration:none;
          }

          #headerImage{
            height:auto;
            max-width: 100% !important;
          }

          /* /\/\/\/\/\/\/\/\/\/\ STANDARD STYLING: MAIN BODY /\/\/\/\/\/\/\/\/\/\ */

          /**
          * @tab Body
          * @section body style
          * @tip Set the background color for your email's body area.
          */
          #templateContainer, .bodyContent{
            /*@editable*/ background-color:#FFFFFF;
          }

          /**
          * @tab Body
          * @section body text
          * @tip Set the styling for your email's main content text. Choose a size and color that is easy to read.
          * @theme main
          */
          .bodyContent div{
            padding: 10px 10%;
            /*@editable*/ color:#606060;
            /*@editable*/ font-family:Helvetica;
            /*@editable*/ font-size:14px;
            /*@editable*/ line-height:150%;
            /*@editable*/ text-align:left;
          }

          /**
          * @tab Body
          * @section body link
          * @tip Set the styling for your email's main content links. Choose a color that helps them stand out from your text.
          */
          .bodyContent div a:link, .bodyContent div a:visited, /* Yahoo! Mail Override */ .bodyContent div a .yshortcuts /* Yahoo! Mail Override */{
            /*@editable*/ color:#606060;
            /*@editable*/ font-weight:normal;
            /*@editable*/ text-decoration:none;
          }

          .bodyContent div a:link .h2, .bodyContent div a:visited, /* Yahoo! Mail Override */ .bodyContent div a .yshortcuts /* Yahoo! Mail Override */{
            /*@editable*/ font-weight:normal;
            /*@editable*/ text-decoration:none;
          }

          p {
            margin-top: 0;
            margin-bottom: 0;
            font-size: 12px;
          }

          .bodyContent img{
            display:inline-block;
            font-size: 12px;
            width: 100px;
            height: 100px;
            height:auto;
          }

          .bodyContent div .clearfix {
            padding: 0px;
            margin-bottom: 30px;
          }

          .clearfix:after {
            content: " ";
            display: block;
            height: 0;
            clear: both;
          }
          div .clearfix {
            clear:both;
          }

          .photo {
            width: 100px;
            height: 100px;
            float: right;
            width: 30%;
            display: inline-block;
          }

          /*.bodyContent .callout {
            width: 22%;
            float: left;
            margin-right: 10px;
            padding: 20px;
          }

          .callout .h2 {
            color: #555;
            font-size: 12px;
          }

          .callout-title {
            text-align: center;
            font-size: 16px;
          }

          .callout p { line-height: 1.5; }

          .callout:first-child {
            padding-left: 8px;
          }

          .callout:nth-child(2n) {
            border-left: 1px solid #eee;
            border-right: 1px solid #eee;
          }

          .callout:last-child {
            margin-right: 0;
          }*/

          .label-blog, .label-discourse, .label-twitter-chat {
            padding: 2px 10px;
            margin-left: 10px;
            font-size: 8px;
            vertical-align: top;
            text-transform: uppercase;
          }

          .label-blog {
            background: lightblue;
            color: blue;
          }

          .label-twitter-chat {
            background: lightgreen;
            color: green;
          }

          .label-discourse {
            background: blanchedalmond;
            color: rgb(204, 109, 6);
          }

          .photo-content {
            width: 70%;
            float:left;
          }

          /* /\/\/\/\/\/\/\/\/\/\ STANDARD STYLING: FOOTER /\/\/\/\/\/\/\/\/\/\ */

          /**
          * @tab Footer
          * @section footer style
          * @tip Set the background color and top border for your email's footer area.
          * @theme footer
          */
          #templateFooter{
            width: 600px;
            /*@editable*/ background-color:#FFFFFF;
            /*@editable*/ border-top:0;
            /*@editable*/ border-bottom:0;
          }

          /**
          * @tab Footer
          * @section footer text
          * @tip Set the styling for your email's footer text. Choose a size and color that is easy to read.
          * @theme footer
          */
          .footerContent div{
            /*@editable*/ color:#606060;
            /*@editable*/ font-family:Helvetica;
            /*@editable*/ font-size:11px;
            /*@editable*/ line-height:125%;
            /*@editable*/ text-align:left;
          }

          /**
          * @tab Footer
          * @section footer link
          * @tip Set the styling for your email's footer links. Choose a color that helps them stand out from your text.
          */
          .footerContent div a:link, .footerContent div a:visited, /* Yahoo! Mail Override */ .footerContent div a .yshortcuts /* Yahoo! Mail Override */{
            /*@editable*/ color:#606060;
            /*@editable*/ font-weight:normal;
            /*@editable*/ text-decoration:underline;
          }

          .footerContent img{
            display:inline;
          }

          /**
          * @tab Footer
          * @section social bar style
          * @tip Set the background color and border for your email's footer social bar.
          * @theme footer
          */
          #social{
            /*@editable*/ background-color:#FAFAFA;
            /*@editable*/ border:0;
          }

          /**
          * @tab Footer
          * @section social bar style
          * @tip Set the background color and border for your email's footer social bar.
          */
          #social div{
            /*@editable*/ text-align:center;
          }

          /**
          * @tab Footer
          * @section utility bar style
          * @tip Set the background color and border for your email's footer utility bar.
          * @theme footer
          */
          #utility{
            /*@editable*/ background-color:#FFFFFF;
            /*@editable*/ border:0;
          }

          /**
          * @tab Footer
          * @section utility bar style
          * @tip Set the background color and border for your email's footer utility bar.
          */
          #utility div{
            /*@editable*/ text-align:center;
          }

          #monkeyRewards img{
            max-width:190px;
          }

          /* CALLOUT STYLES */
          .callout a {
            text-decoration: none;
          }
          
          div.callout {
            width: 100% !important;
            min-width: 100% !important;
            padding: 0px !important;
            border-left: none !important;
            border-right: none !important;
            padding-bottom: 20px !important;
            margin-bottom: 20px !important;
            text-align: center;
          }

          .callout .h2 {
            margin-bottom: 0px !important;
            font-size: 17px !important;
            text-align: center;
            color: black;
            line-height: 150% !important;
          }

          .callout:last-child {
            border: none;
          }

          .callout-title {
            background: #7ed321;
            padding: 10px 0px;
            margin-bottom: 30px !important;
            color: white !important;
            font-size: 17px !important;
            text-align: center;
          }
              
          .callout p {
            font-size: 12px !important;
            line-height: 150% !important;
            color: black !important;
            margin-bottom: 0;
            font-family: sans-serif;
          }

          /* /\/\/\/\/\/\/\/\/ MOBILE STYLES /\/\/\/\/\/\/\/\/ */
             @media only screen and (max-width:480px){
               #templateBody, #templateContainer, #templatePreheader, #templateHeader, #headerImage, #headerContent,
               #templateFooter, img #headerImage #campaign-icon {
                 color:#CCCCCC !important;
                 font-size:20px !important;
                 max-width: 320px;
               }

              img.photo { float: left !important; }

              .photo-content {
                width: 100% !important;
                padding-bottom: 20px !important;
              }

              .clearfix { padding: 10px 0px !important; }

              p {
                font-size: 17px !important;
                line-height: 150% !important;
                color: black !important;
                margin-bottom: 0;
              }

              .h2 {
                font-size: 20px !important;
                color: black !important;
                font-weight: 900 !important;
                line-height: 150% !important;
              }

              .preview p, .archive-text {
                font-size:8px !important;
                color:#505050 !important;
                font-family: Arial !important;
                line-height: 100% !important;
                text-align: left !important;
              }

              .archive-text{
                text-align: left !important;
              }
            }
          }
        </style>
      </head>
    DOC
    template.puts <<-DOC
    <body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0">
      <center>
          <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="backgroundTable">
              <tr>
                  <td align="center" valign="top">
                        <!-- // Begin Template Preheader \\ -->
                        <table border="0" cellpadding="10" cellspacing="0" id="templatePreheader">
                            <tr>
                                <td valign="top" class="preheaderContent">
                                  <!-- // Begin Module: Standard Preheader \ -->
                                    <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                      <tr>
                                          <td valign="top" width="50%">
                                              <div class="preview" mc:edit="std_preheader_content">
                                                #{meta.preview_text}
                                              </div>
                                            </td>
                                            <!-- *|IFNOT:ARCHIVE_PAGE|* -->
                      <td valign="top" width="50%">
                                              <div mc:edit="std_preheader_links" style="text-align: right">
                                                  <p class="archive-text">Is this email not displaying correctly?<br /><a href="*|ARCHIVE|*" target="_blank">View it in your browser</a>.</p>
                                                </div>
                                            </td>
                      <!-- *|END:IF|* -->
                                        </tr>
                                    </table>
                                  <!-- // End Module: Standard Preheader \ -->
                                </td>
                            </tr>
                        </table>
                        <!-- // End Template Preheader \\ -->
                      <table border="0" cellpadding="0" cellspacing="0" id="templateContainer">
                          <tr>
                              <td align="center" valign="top">
                                    <!-- // Begin Template Header \\ -->
                                  <table border="0" cellpadding="0" cellspacing="0" id="templateHeader">
                                        <tr>
                                            <td class="headerContent">
                                              <!-- // Begin Module: Standard Header Image \\ -->
                                              <img src="#{meta.header_image}" style="max-width:100%;" id="headerImage campaign-icon" mc:label="header_image" mc:edit="header_image" mc:allowdesigner mc:allowtext />
                                              <!-- // End Module: Standard Header Image \\ -->

                                            </td>
                                        </tr>
                                    </table>
                                    <!-- // End Template Header \\ -->
                                </td>
                            </tr>
                            <tr> 
                              <td align="center" valign="top">
                                    <!-- // Begin Template Body \\ -->
                                  <table border="0" cellpadding="0" cellspacing="0" id="templateBody">
                                      <tr>
                                            <td valign="top" class="bodyContent">
                                                <!-- // Begin Module: Standard Content \\ -->
                                                <table border="0" cellpadding="20" cellspacing="0" width="100%">
                                                  <tr>
    DOC
    content_lists.each do |list|
      template.puts "<tr>"
      template.puts "<td valign=\"top\">"
      template.puts "<div class=\"clearfix\">"
      template.puts "<h1 class=\"h1\">#{list.name}</h1>"
      template.puts"<hr />"
      template.puts "</div>"
      list.cards.each do |card|
        post = Post.new(card)
        if post.attachment
          stripped_post = post.body.gsub("<p>","").gsub("</p>","")
          template.puts "<div class=\"clearfix\" style=\"clear:both;\">"
          template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}</h2></a>"
          template.puts "    <p class=\"photo-content\">#{stripped_post}</p>"
          template.puts "    <a href=\"#{post.link}\" target=\"_blank\"><img class=\"photo\" src=\"#{post.attachment}\" alt=\"Blog guest picture\"></a>"
          template.puts "</div>"
        else
          template.puts "<div class=\"clearfix\">"
          template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}<span class=\"label-#{post.label.gsub(" ", "-") if post.label}\">#{post.label}</span></h2></a>"
          template.puts "    #{post.body}"
          template.puts "</div>"
        end
      end
      template.puts "</td>"
      template.puts "</tr>"
    end
    template.puts "<tr>"
    template.puts "<td valign=\"top\">"
    template.puts "<div class=\"clearfix\">"
    template.puts "<h1 class=\"h1\">#{sponsors.name}</h1>"
    template.puts"<hr />"
    template.puts "</div>"
    sponsors.cards.each do |card|
      post = Post.new(card)
      stripped_post = post.body.gsub("<p>","").gsub("</p>","")
      template.puts "<div class=\"clearfix\" style=\"clear:both;\">"
      template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}</h2></a>"
      template.puts "    <p class=\"photo-content\">#{stripped_post}</p>"
      template.puts "    <a href=\"#{post.link}\" target=\"_blank\"><img class=\"photo\" src=\"#{post.attachment}\" alt=\"Blog guest picture\"></a>"
      template.puts "</div>"
    end
    template.puts "</td>"
    template.puts "</tr>"
    template.puts "<tr>"
    template.puts "<td valign=\"top\">"
    template.puts "<div class=\"clearfix\">"
    template.puts "<h1 class=\"callout-title\">Join us</h1>"
    template.puts "</div>"
    callouts.cards.each do |card|
      post = Post.new(card)
      template.puts "<div class=\"callout\">"
      template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}</h2></a>"
      template.puts "    #{post.body}"
      template.puts "</div>"
    end
    template.puts "</td>"
    template.puts "</tr>"
    template.puts "<tr>"
    template.puts "</tr>"
    template.puts <<-DOC
                    </tr>
                        </table>
                                 <!-- // End Module: Standard Content \\ -->
                                              </td>
                                          </tr>
                                      </table>
                                      <!-- // End Template Body \\ -->
                                  </td>
                              </tr>
                            <tr>
                                <td align="center" valign="top">
                                      <!-- // Begin Template Footer \\ -->
                                    <table border="0" cellpadding="10" cellspacing="0" id="templateFooter">
                                        <tr>
                                            <td valign="top" class="footerContent">
                                                  <!-- // Begin Module: Standard Footer \\ -->
                                                  <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                                      <tr>
                                                          <td colspan="2" valign="middle" id="social">
                                                              <div mc:edit="std_social">
                                                                  &nbsp;<a href="*|TWITTER:PROFILEURL|*">Follow us @CodeNewbie</a> | <a href="*|FORWARD|*">forward to a friend</a> | <a href="http://codenewbie.org/">Visit us at www.codenewbie.org</a> | <a href="mailto:hello@codenewbie.org"> Email Us </a>&nbsp;
                                                              </div>
                                                          </td>
                                                      </tr>
                                                      <tr>
                                                          <td valign="top" width="350">
                                                              <div mc:edit="std_footer">
                                  <em>Copyright &copy; *|CURRENT_YEAR|* *|LIST:COMPANY|*, All rights reserved.</em>
                                  *|IFNOT:ARCHIVE_PAGE|* *|LIST:DESCRIPTION|* *|END:IF|*
                                  </div>
                                                          </td>
                                                      </tr>
                                                      <tr>
                                                          <td colspan="2" valign="middle" id="utility">
                                                              <div mc:edit="std_utility">
                                                                  &nbsp;<a href="*|UNSUB|*">unsubscribe from this list</a> | <a href="*|UPDATE_PROFILE|*">update subscription preferences</a>&nbsp;
                                                              </div>
                                                          </td>
                                                      </tr>
                                                  </table>
                                                  <!-- // End Module: Standard Footer \\ -->
                                              </td>
                                          </tr>
                                      </table>
                                      <!-- // End Template Footer \\ -->
                                  </td>
                              </tr>
                          </table>
                      </td>
                  </tr>
              </table>
          </center>
      </body>
  </html>
    DOC
    template.close
  end

  # https://apidocs.mailchimp.com/api/2.0/campaigns/create.php
  # https://apidocs.mailchimp.com/api/2.0/lists/list.php
  def export_to_mailchimp(email_subject)
    puts "exporting to mailchimp!"
    gb = Gibbon::API.new(ENV['MAILCHIMP_KEY'])
    recipient_list = gb.lists.list({:filters => {:list_name => "From Website"}})
    list_id = recipient_list['data'].first['id']
    zipfile = File.open("newsletter_html.zip", "r") { |fp| fp.read }
    begin
      gb.campaigns.create({type: "regular", options: {list_id: list_id, subject: email_subject, 
                                                    from_email: "hello@codenewbie.org", from_name: "#CodeNewbie", 
                                                    generate_text: true, inline_css: true}, 
                                                    content: {archive:Base64.encode64(zipfile) , archive_type: "zip"}})
    rescue Gibbon::MailChimpError => e
      puts "The zip file upload errored: #{e.message}"
      puts "Try to upload contents of index.html"
      file = File.open("index.html", "r")
      contents = file.read
      gb.campaigns.create({type: "regular", options: {list_id: list_id, subject: email_subject, 
                                                    from_email: "hello@codenewbie.org", from_name: "#CodeNewbie", 
                                                    generate_text: true, inline_css: true}, 
                                                    content: {html: contents}})
    end
  end
end
