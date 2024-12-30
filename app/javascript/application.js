// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require jquery
//= require jquery_ujs
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"
import "trix"
import "@rails/actiontext"
import LocalTime from "local-time"

LocalTime.start()

//$( document ).on('ready', function() {
//});

// Listener for completion of form submission
$(document).on('turbo:submit-end', function() {
    showNotice();
});

// listener for new page load
$(document).on('turbo:load', function() {
    // Disable submit for parts CSV import
    $('#part-import input[type="submit"]').prop('disabled', true);

    // On Click handlers
    $('#error_explanation').on('click', function(e) {
        $('.error-toggle').toggleClass('hidden');
        $('#error_explanation').toggleClass('open');
        e.preventDefault();
    });

    $('#mobile-icon').on('click', function(e) {
        $(this).toggleClass('active');
        $('nav').toggleClass('mobile-open');
        e.stopPropagation();
        e.preventDefault();
    });

    // On Change handlers
    $('#part-import input[type="file"]').on('change', function() {
        if ($(this).length > 0) {
            $(this).parent().find('input[type="submit"]').prop('disabled', false);
        }
    });

    // Timer handlers 
    //  ....Vanishing notices
    showNotice();

    // Scroll to top functionality 
    // 1. Show button upon scroll
    window.onscroll = function() {
        if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
            $('#to-top').toggleClass("show", true);
        } else {
            $('#to-top').toggleClass("show", false);
        }
    }
    // 2. OnClick function that scrolls to top
    $('#to-top').on('click', () => {
        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    });

    // call mobile table headers function 
    mobileTableHeaders();

    // Typing effect on landing page
    const words = ["inventory.", "ordering.", "tracking."];
    let i = 0;
    let timer;

    function typingEffect() {
        let word = words[i].split("");
        var loopTyping = function() {
            if (word.length > 0) {
                document.getElementById('word').innerHTML += word.shift();
            } else {
                deletingEffect();
                return false;
            }
            timer = setTimeout(loopTyping, 300);
        };
        loopTyping();
    };

    function deletingEffect() {
        let word = words[i].split("");
        var loopDeleting = function() {
            if (word.length > 0) {
                word.pop();
                document.getElementById('word').innerHTML = word.join("");
            } else {
                if (words.length > (i + 1)) {
                    i++;
                } else {
                    i = 0;
                };
                typingEffect();
                return false;
            };
            timer = setTimeout(loopDeleting, 200);
        };
        loopDeleting();
    };

    if(document.getElementById('word')) {
        typingEffect();      
    }

    function showNotice() {
        //  ....Vanishing notices
        setTimeout(function() {
            $('#notice').toggleClass('timeout', true);
            $('#modal_notice').toggleClass('timeout', true);
            setTimeout(function() {
                $('#notice').toggleClass('hidden', true);
                $('#modal_notice').toggleClass('hidden', true);
            }, 6000);
        }, 6000);
    }
});