##
##  Copy & Paste Tool for images to PowerPoint(.pptx)
##
import pptx
import pptx.util
import glob
import matplotlib.image as mpimg

OUTPUT_TAG = "SWIFT_ppt"

# new
prs = pptx.Presentation()
# open
# prs_exists = pptx.Presentation("some_presentation.pptx")

# default slide width
#prs.slide_width = 9144000
# slide height @ 4:3
#prs.slide_height = 6858000
# slide height @ 16:9
prs.slide_height = 5143500

# title slide
slide = prs.slides.add_slide(prs.slide_layouts[0])
# blank slide
#slide = prs.slides.add_slide(prs.slide_layouts[6])

# set title
title = slide.shapes.title
title.text = OUTPUT_TAG

pic_left  = int(prs.slide_width * 0.15)
pic_top   = int(prs.slide_height * 0.01)

for g in glob.glob("images/*"):
    print(g)
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    shapes = slide.shapes
    img = mpimg.imread(g)
    # check aspect ratio and set width and height
    if img.shape[1] > img.shape[0]:  # w > h
        pic_width = int(prs.slide_width * 0.7)
        pic_height = int(pic_width * img.shape[0] / img.shape[1])
    else:
        pic_height = int(prs.slide_height * 0.98)
        pic_width = int(pic_height * img.shape[1] / img.shape[0])
    pic_left  = int((prs.slide_width - pic_width) * 0.5)
    pic_top  = int((prs.slide_height - pic_height) * 0.5)
    #pic   = slide.shapes.add_picture(g, pic_left, pic_top)
    pic   = slide.shapes.add_picture(g, pic_left, pic_top, pic_width, pic_height)

prs.save("%s.pptx" % OUTPUT_TAG)
