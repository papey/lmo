# qrcode
require 'rqrcode'
require 'erb'

# Tiny class handling all the variables
class Filler

    # init values
    def initialize values, delay, qr, templates="./filler/templates"
        # get current time
        now = Time.now

        # translation from english to french
        @translate = Hash["work" => "travail", "purchase" => "achats", "health" => "sante",
            "familly" => "famille", "handicap" => "handicap", "pets" => "sport_animaux",
            "sport" => "sport_animaux", "justice" => "convocation", "missions" => "missions",
            "children" => "enfants"]

        values["LMO_REASON"] = @translate[values["LMO_REASON"]]

        # map values fetch from env or cli
        @values = values

        # templates
        @qr = File.read("#{templates}/qrcode.erb")
        @text = File.read("#{templates}/attestation.erb")

        # handle delay if specified
        if delay != nil then
            time = now + delay*60
        else
            time = now
        end

        # dedicated attribute
        @date = time.strftime("%d/%m/%Y")
        @time = time.strftime("%H:%M")
    end

    # generate string
    def fill
        ERB.new(@text).result(binding)
    end

    def fill_qr
        ERB.new(@qr).result(binding)
    end

    def gen_qr()
        qr = RQRCode::QRCode.new(self.fill_qr)
    end

    def id
        date = Time.now.strftime("%d/%m/%Y - %H:%M")
        "#{@values["LMO_NAME"]} - #{@values["LMO_FIRSTNAME"]} - #{date}"
    end

end
