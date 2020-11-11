# Belt Counter

An app made with [Flutter](https://flutter.dev) made to help calculating chain density on a conveyor belt easy, especially for high density belts.

## Motivation

My dad at the time of building this app is a salesman for conveyor belts, and part of his job includes going to factories and, if neccessary, helping
troubleshoot any problems with the belts, and documenting belt density is important, but it can be very difficult when the chains are small, and there
are lots of them. This app's goal is to make that easier.

## Design Proccess

#### UX

The goals I had were:

- Make the app as simple as possible
- Don't plague the UX with Snapchat's annoyances

There were three iterations I went through on the design, in this order: 

**The main screen is the analysis, taking the picture is the secondary screen**

This design was _okay_, and as you'll see, it's close to the one I ended on, but in the end, I decided it was too much friction. I didn't want
to have to explain anything. I wanted the app to be so intuitive, it didn't need instructions. That extra step of having to figure out
how to take the picture wasn't what I wanted, so I scrapped the design.

**There is only one screen, and it analyzes the viewfinder in real time**

This design is still my favorite, but unfortunately, it was not performant at all. This is mainly because in Flutter, the Image library expects
an array of bytes, which is easy to read from a file, but the previews streamed from the viewfinder come in a different format that needs converted,
and doing that on every update was very computationally expensive, and the app ended up crashing every time.

**Taking the picture is the main screen, analysis is the secondary screen**

While the previous idea wasn't performant enough to stick, I did really like having the viewfinder as the primary screen, so I decicded to stick with it.

#### Algorithm

There are many very complicated ways to solve this problem of counting chains. I am not Google, and do not have AI expertise. The algorithm isn't perfect,
and is a WIP, but here is what I currently do:

- Have the phone owner print and cut a green piece of paper in a rectangle with the short side being 1 inch long
- Put the paper in the frame
- Calculate pixel density knowing the short side of the green paper is 1 inch
- Grab a 1in x 1in square of the belt to look at
- Count the amount of times pixel goes from white to black, as there are shadows between the chains
