require "dragonfly/hash_with_css_style_keys"
require "dragonfly/image_magick/commands" if File.exist?("dragonfly/image_magick/commands.rb")

module AvatarMagick
  module Generators

    # Generates an initials avatar by extracting the first letter of
    # the first 3 words in string. Can be customized with background color,
    # text color, font, and size.
    class InitialAvatar
      def call(content, string, opts={})
        opts = ::Dragonfly::HashWithCssStyleKeys[opts]
        args = []

        # defaults
        format      = opts[:format] || 'png'
        background  = opts[:background_color] ? "##{opts[:background_color]}" : content.env[:avatar_magick][:background_color]
        color       = opts[:color] ? "##{opts[:color]}" : content.env[:avatar_magick][:color]
        size        = opts[:size] || content.env[:avatar_magick][:size]
        font        = opts[:font] || content.env[:avatar_magick][:font]

        # extract the first letter of the first 3 words and capitalize
        text = (string.split(/\s/)- ["", nil]).map { |t| t[0].upcase }.slice(0, 3).join('')

        w, h = size.split('x').map { |d| d.to_i }
        h ||= w

        font_size = ( w / [text.length, 2].max ).to_i

        # Settings
        args.push("-gravity none")
        args.push("-antialias")
        args.push("-pointsize #{font_size}")
        args.push("-font \"#{font}\"")
        args.push("-family '#{opts[:font_family]}'") if opts[:font_family]
        args.push("-fill #{color}")
        args.push("-background #{background}")
        args.push("label:#{text}")

        if defined?(Dragonfly::ImageMagick::Commands)
          Dragonfly::ImageMagick::Commands.generate(content, args.join(' '), format)
        else
          content.generate!(:convert, args.join(' '), format)
        end

        args.clear
        args.push("-gravity center")
        args.push("-extent #{w}x#{h}")

        if defined?(Dragonfly::ImageMagick::Commands)
          Dragonfly::ImageMagick::Commands.convert(content, args.join(' '))
        else
          content.process!(:convert, args.join(' '))
        end

        content.add_meta('format' => format, 'name' => "avatar.#{format}")
      end
    end
  end
end
