import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particle_field/particle_field.dart';
import 'package:rnd/rnd.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Particle Field Demo',
      debugShowCheckedModeBanner: false,
      home: ParticleFieldExample(),
    );
  }
}

// this is a very quick and dirty example.
class ParticleFieldExample extends StatelessWidget {
  const ParticleFieldExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SpriteSheet sparkleSpriteSheet = SpriteSheet(
      image: const AssetImage('assets/particle-21x23.png'),
      frameWidth: 21,
      scale: 0.75,
    );

    /// particle_fieldのオリジナル
    // super simple ParticleField example:
    final ParticleField field = ParticleField(
      spriteSheet: sparkleSpriteSheet,
      // top left will be 0,0:
      origin: Alignment.topLeft,
      // onTick is where all the magic happens:
      onTick: (controller, elapsed, size) {
        List<Particle> particles = controller.particles;
        // add a new particle each frame:
        particles.add(Particle(x: rnd(size.width), vx: rnd(-1, 1)));
        // update existing particles:
        for (int i = particles.length - 1; i >= 0; i--) {
          Particle particle = particles[i];
          // call update, which automatically adds vx/vy to x/y
          // also add some gravity (ie. increase vertical velocity)
          // and increment the frame
          particle.update(vy: particle.vy + 0.1, frame: particle.frame + 1);
          // remove particle if it's out of bounds:
          if (!size.contains(particle.toOffset())) particles.removeAt(i);
        }
      },
    );

    /// flutter-wonderous-appから引用
    final Color color = Colors.orange;
    int particleCount = 1200;
    final int fadeMs = 6000000;

    final ParticleField field2 = ParticleField(
      blendMode: BlendMode.dstIn,
      spriteSheet: sparkleSpriteSheet,
      onTick: (controller, elapsed, size) {
        List<Particle> particles = controller.particles;

        // calculate base distance from center & velocity based on width/height:
        final double d = min(size.width, size.height) * 0.3;
        final double v = d * 0.08;

        // calculate an opacity multiplier based on time elapsed (ie. fade out):
        controller.opacity = Curves.easeOutExpo
            .transform(max(0, 1 - elapsed.inMilliseconds / fadeMs));
        if (controller.opacity == 0) return;

        // add new particles, reducing the number added each tick:
        int addCount = particleCount ~/ 30;
        particleCount -= addCount;
        while (--addCount > 0) {
          final double angle = rnd.getRad();
          particles.add(Particle(
            // adding random variation makes it more visually interesting:
            x: cos(angle) * d * rnd(0.8, 1),
            y: sin(angle) * d * rnd(0.8, 1),
            vx: cos(angle) * v * rnd(0.5, 1.5),
            vy: sin(angle) * v * rnd(0.5, 1.5),
            color: color.withOpacity(rnd(0.5, 1)),
          ));
        }

        // update existing particles & remove old ones:
        for (int i = particles.length - 1; i >= 0; i--) {
          final Particle o = particles[i];
          o.update(frame: o.age ~/ 3);
          if (o.age > 40) particles.removeAt(i);
        }
      },
    );

    return Scaffold(
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFFFF0000),
          fontSize: 48,
          fontWeight: FontWeight.w100,
          height: 1,
        ),
        child: Container(
          color: const Color(0xFF110018),
          child: Stack(children: [
            const Center(child: Text("Particle Field")),
            Positioned.fill(
              // scale the field up just a bit for some "overscan"
              // so particles can go past the edges:
              child: Transform.scale(scale: 1.05, child: field2),
            ),
          ]),
        ),
      ),
    );
  }
}
