local aspectRatio = display.pixelHeight / display.pixelWidth
_G.application = {
	content = {
		width = aspectRatio > 1.5 and 640 or math.floor( 960 / aspectRatio ),
		height = aspectRatio < 1.5 and 960 or math.floor( 640 * aspectRatio ),
		scale  = "letterBox",
		fps    = 60,

		imageSuffix =
		{
				["@2x"] = 1.5,   -- A good scale for Retina
		}
	},
	-- license = -- Take this from google play IAP info
    -- {
    --     google =
    --     {
    --         key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw5o6wpbHCgxiqHEf1i1jwFbBx0TD/2EONkOe6R690Upxv+N3vkTpV9jklVDb1lw/FWmkr8RdbnvxAX3sgRMzEv/6ymcTOQklR8YvNHw1oIlG+H6sduzytE1Ci0bLVBUmIyLdrMAN8NQrbi/TeTzTt55K+jnLL3B8z4RgAUV+VJeALgqoqleaFXf9/bCoFhpxqMTHBwOlI2zm7QQPNL6K4y1hbj3t7ZOyIrNm/QXbbYptMoiW/+iaqZBU+riBY8mqsbhqsBeUVy3KefuWH1BwULuanPO/0q1oWjqNtDUcPEEZb+tSUIbGB670mq/UXDSANMYwO0yYmtlhPka+R0XLMwIDAQAB",
    --     },
    -- },
}
